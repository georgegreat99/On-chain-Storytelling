;; On-chain Storytelling DAO
;; Writers propose and vote on new chapters of a story, stored forever on-chain

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u101))
(define-constant ERR_VOTING_ENDED (err u102))
(define-constant ERR_ALREADY_VOTED (err u103))
(define-constant ERR_INSUFFICIENT_VOTES (err u104))

;; Data Variables
(define-data-var next-chapter-id uint u1)
(define-data-var next-proposal-id uint u1)
(define-data-var voting-period uint u1440) ;; blocks (~10 days)
(define-data-var min-votes-required uint u3)

;; Data Maps
(define-map chapters 
    uint 
    {
        content: (string-ascii 2000),
        author: principal,
        block-height: uint,
        proposal-id: uint
    }
)

(define-map proposals 
    uint 
    {
        chapter-content: (string-ascii 2000),
        proposer: principal,
        votes-for: uint,
        votes-against: uint,
        end-block: uint,
        executed: bool
    }
)

(define-map votes 
    {proposal-id: uint, voter: principal} 
    bool
)

;; Chapter Management Functions

(define-public (propose-chapter (content (string-ascii 2000)))
    (let ((proposal-id (var-get next-proposal-id))
          (end-block (+ block-height (var-get voting-period))))
        (map-set proposals proposal-id {
            chapter-content: content,
            proposer: tx-sender,
            votes-for: u0,
            votes-against: u0,
            end-block: end-block,
            executed: false
        })
        (var-set next-proposal-id (+ proposal-id u1))
        (ok proposal-id)
    )
)

(define-public (vote-on-proposal (proposal-id uint) (vote-for bool))
    (let ((proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND))
          (voter-key {proposal-id: proposal-id, voter: tx-sender}))
        (asserts! (<= block-height (get end-block proposal)) ERR_VOTING_ENDED)
        (asserts! (is-none (map-get? votes voter-key)) ERR_ALREADY_VOTED)

        (map-set votes voter-key vote-for)

        (if vote-for
            (map-set proposals proposal-id (merge proposal {votes-for: (+ (get votes-for proposal) u1)}))
            (map-set proposals proposal-id (merge proposal {votes-against: (+ (get votes-against proposal) u1)}))
        )
        (ok true)
    )
)

(define-public (execute-proposal (proposal-id uint))
    (let ((proposal (unwrap! (map-get? proposals proposal-id) ERR_PROPOSAL_NOT_FOUND)))
        (asserts! (> block-height (get end-block proposal)) ERR_VOTING_ENDED)
        (asserts! (not (get executed proposal)) ERR_UNAUTHORIZED)
        (asserts! (>= (get votes-for proposal) (var-get min-votes-required)) ERR_INSUFFICIENT_VOTES)
        (asserts! (> (get votes-for proposal) (get votes-against proposal)) ERR_INSUFFICIENT_VOTES)

        (let ((chapter-id (var-get next-chapter-id)))
            (map-set chapters chapter-id {
                content: (get chapter-content proposal),
                author: (get proposer proposal),
                block-height: block-height,
                proposal-id: proposal-id
            })
            (map-set proposals proposal-id (merge proposal {executed: true}))
            (var-set next-chapter-id (+ chapter-id u1))
            (ok chapter-id)
        )
    )
)

;; Read-only Functions

(define-read-only (get-chapter (chapter-id uint))
    (map-get? chapters chapter-id)
)

(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
    (map-get? votes {proposal-id: proposal-id, voter: voter})
)

(define-read-only (get-total-chapters)
    (- (var-get next-chapter-id) u1)
)

(define-read-only (get-story-so-far)
    (let ((total-chapters (get-total-chapters)))
        (if (> total-chapters u0)
            (get-chapters-range u1 total-chapters)
            (list)
        )
    )
)

(define-read-only (get-chapters-range (start uint) (end uint))
    (map get-chapter-data (list start))
)

(define-read-only (get-chapter-data (chapter-id uint))
    (default-to 
        {content: "", author: CONTRACT_OWNER, block-height: u0, proposal-id: u0}
        (map-get? chapters chapter-id)
    )
)

;; Admin Functions

(define-public (set-voting-period (new-period uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (var-set voting-period new-period)
        (ok true)
    )
)

(define-public (set-min-votes (new-min uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (var-set min-votes-required new-min)
        (ok true)
    )
)