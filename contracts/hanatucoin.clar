;; Hanatucoin (HANA) - A Stacks SIP-010 Fungible Token
;; This smart contract implements a fungible token called Hanatucoin (HANA)
;; following the SIP-010 standard for fungible tokens on Stacks.

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-transfer-failed (err u103))
(define-constant err-mint-failed (err u104))
(define-constant err-burn-failed (err u105))
(define-constant err-invalid-amount (err u106))
(define-constant err-invalid-recipient (err u107))

;; Token definition
(define-fungible-token hanatucoin)

;; Token metadata
(define-constant token-name "Hanatucoin")
(define-constant token-symbol "HANA")
(define-constant token-decimals u6) ;; 6 decimal places
(define-constant token-uri u"https://hanatucoin.com/metadata")

;; Maximum supply: 1 billion HANA tokens
(define-constant max-supply u1000000000000000) ;; 1B tokens with 6 decimals

;; Data variables
(define-data-var token-total-supply uint u0)
(define-data-var contract-owner-address principal contract-owner)
(define-data-var paused bool false)

;; Data maps
(define-map authorized-minters principal bool)
(define-map token-balances principal uint)

;; Initialize contract with initial supply to contract owner
(define-private (initialize)
  (let 
    (
      (initial-supply u100000000000000) ;; 100M tokens initial supply
    )
    (try! (ft-mint? hanatucoin initial-supply contract-owner))
    (var-set token-total-supply initial-supply)
    (map-set token-balances contract-owner initial-supply)
    (ok true)
  )
)

;; Call initialize on contract deployment
(initialize)

;; SIP-010 Standard Functions

;; Transfer tokens
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (not (var-get paused)) err-transfer-failed)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (try! (ft-transfer? hanatucoin amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

;; Get token name
(define-read-only (get-name)
  (ok token-name)
)

;; Get token symbol
(define-read-only (get-symbol)
  (ok token-symbol)
)

;; Get token decimals
(define-read-only (get-decimals)
  (ok token-decimals)
)

;; Get balance of a principal
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance hanatucoin who))
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok (ft-get-supply hanatucoin))
)

;; Get token URI
(define-read-only (get-token-uri)
  (ok (some token-uri))
)

;; Administrative Functions

;; Set contract owner
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner-address)) err-owner-only)
    (var-set contract-owner-address new-owner)
    (ok true)
  )
)

;; Get contract owner
(define-read-only (get-contract-owner)
  (var-get contract-owner-address)
)

;; Pause/unpause contract
(define-public (set-paused (pause bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner-address)) err-owner-only)
    (var-set paused pause)
    (ok true)
  )
)

;; Check if contract is paused
(define-read-only (is-paused)
  (var-get paused)
)

;; Minting Functions

;; Authorize a principal to mint tokens
(define-public (set-minter (minter principal) (authorized bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner-address)) err-owner-only)
    (map-set authorized-minters minter authorized)
    (ok true)
  )
)

;; Check if a principal is authorized to mint
(define-read-only (is-minter (who principal))
  (default-to false (map-get? authorized-minters who))
)

;; Mint tokens (only authorized minters or contract owner)
(define-public (mint (amount uint) (recipient principal))
  (let 
    (
      (current-supply (ft-get-supply hanatucoin))
      (new-supply (+ current-supply amount))
    )
    (asserts! (not (var-get paused)) err-mint-failed)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (<= new-supply max-supply) err-mint-failed)
    (asserts! (or 
                (is-eq tx-sender (var-get contract-owner-address))
                (is-minter tx-sender)
              ) err-owner-only)
    (try! (ft-mint? hanatucoin amount recipient))
    (var-set token-total-supply new-supply)
    (ok true)
  )
)

;; Burn tokens (token holder can burn their own tokens)
(define-public (burn (amount uint))
  (let
    (
      (sender-balance (ft-get-balance hanatucoin tx-sender))
    )
    (asserts! (not (var-get paused)) err-burn-failed)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= sender-balance amount) err-insufficient-balance)
    (try! (ft-burn? hanatucoin amount tx-sender))
    (let
      (
        (new-supply (- (ft-get-supply hanatucoin) amount))
      )
      (var-set token-total-supply new-supply)
      (ok true)
    )
  )
)

;; Utility Functions

;; Get maximum supply
(define-read-only (get-max-supply)
  (ok max-supply)
)

;; Check if amount would exceed max supply
(define-read-only (would-exceed-max-supply (additional-amount uint))
  (let
    (
      (current-supply (ft-get-supply hanatucoin))
      (projected-supply (+ current-supply additional-amount))
    )
    (> projected-supply max-supply)
  )
)

;; Batch transfer function for airdrops or distributions
(define-public (batch-transfer (recipients (list 200 {recipient: principal, amount: uint})) (memo (optional (buff 34))))
  (begin
    (asserts! (not (var-get paused)) err-transfer-failed)
    (asserts! (or 
                (is-eq tx-sender (var-get contract-owner-address))
                (is-minter tx-sender)
              ) err-owner-only)
    (fold batch-transfer-helper recipients (ok true))
  )
)

;; Helper function for batch transfers
(define-private (batch-transfer-helper (transfer-data {recipient: principal, amount: uint}) (previous-result (response bool uint)))
  (match previous-result
    success 
      (let
        (
          (recipient (get recipient transfer-data))
          (amount (get amount transfer-data))
        )
        (if (> amount u0)
          (ft-transfer? hanatucoin amount tx-sender recipient)
          (ok true)
        )
      )
    error (err error)
  )
)

;; title: hanatucoin
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

