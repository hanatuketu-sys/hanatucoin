;; HanatuBit (HBT) - SIP-010-style fungible token

(define-constant token-name "HanatuBit")
(define-constant token-symbol "HBT")
(define-constant token-decimals u6)

(define-constant err-unauthorized (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-same-sender-recipient (err u103))

(define-data-var total-supply uint u0)
(define-constant contract-owner tx-sender)

(define-map balances principal uint)

(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-balance (who principal))
  (ok (default-to u0 (map-get? balances who)))
)

(define-private (transfer-internal (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (not (is-eq sender recipient)) err-same-sender-recipient)
    (let ((sender-balance (default-to u0 (map-get? balances sender))))
      (asserts! (>= sender-balance amount) err-insufficient-balance)
      (map-set balances sender (- sender-balance amount))
      (let ((recipient-balance (default-to u0 (map-get? balances recipient))))
        (map-set balances recipient (+ recipient-balance amount))
      )
      (ok true)
    )
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (transfer-internal amount sender recipient)
  )
)

(define-public (transfer-memo (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (let ((result (transfer-internal amount sender recipient)))
      (match result
        okv (begin
              (match memo m
                (begin (print {event: "transfer-memo", amount: amount, sender: sender, recipient: recipient, memo: m}) true)
                true)
              (ok okv)
            )
        errv (err errv)
      )
    )
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (> amount u0) err-invalid-amount)
    (var-set total-supply (+ (var-get total-supply) amount))
    (let ((rb (default-to u0 (map-get? balances recipient))))
      (map-set balances recipient (+ rb amount))
    )
    (ok true)
  )
)

(define-public (burn (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (let ((bal (default-to u0 (map-get? balances tx-sender))))
      (asserts! (>= bal amount) err-insufficient-balance)
      (map-set balances tx-sender (- bal amount))
      (var-set total-supply (- (var-get total-supply) amount))
      (ok true)
    )
  )
)
