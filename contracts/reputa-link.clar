;; ReputaLink - Next-Generation Social Proof Protocol
;;
;; A revolutionary blockchain-based social validation ecosystem that transforms
;; how trust and credibility are built in digital communities. ReputaLink 
;; leverages Bitcoin's security through Stacks to create tamper-proof social
;; interactions, skill validations, and reputation scoring.
;;
;; Key Features:
;; - Immutable reputation tracking with weighted endorsements
;; - Incentivized content creation through algorithmic rewards
;; - Decentralized peer-to-peer skill validation system
;; - Anti-spam mechanisms with reputation-based gatekeeping
;; - Community-driven content curation and moderation
;;
;; Built for the future of decentralized social networks where trust is
;; earned, verified, and permanently recorded on the blockchain.

;; ERROR CONSTANTS

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-insufficient-reputation (err u105))
(define-constant err-self-endorsement (err u106))
(define-constant err-already-endorsed (err u107))

;; GLOBAL STATE VARIABLES

(define-data-var next-user-id uint u1)
(define-data-var next-post-id uint u1)
(define-data-var next-endorsement-id uint u1)
(define-data-var platform-fee uint u100) ;; 1% fee in basis points
(define-data-var min-reputation-for-rewards uint u100) ;; Minimum reputation threshold

;; CORE DATA STRUCTURES

;; User Profile Storage
(define-map users
  { user-address: principal }
  {
    user-id: uint,
    username: (string-ascii 32),
    bio: (string-utf8 256),
    reputation-score: uint,
    total-posts: uint,
    total-likes-received: uint,
    total-endorsements-received: uint,
    joined-at: uint,
    is-verified: bool,
  }
)

;; User ID Lookup Table
(define-map user-by-id
  { user-id: uint }
  { user-address: principal }
)

;; Content Posts Storage
(define-map posts
  { post-id: uint }
  {
    author: principal,
    content: (string-utf8 512),
    timestamp: uint,
    likes: uint,
    reposts: uint,
    replies: uint,
    reputation-earned: uint,
    is-active: bool,
    tags: (list 5 (string-ascii 32)),
  }
)

;; Post Engagement Tracking
(define-map post-likes
  {
    post-id: uint,
    liker: principal,
  }
  { timestamp: uint }
)

(define-map post-reposts
  {
    post-id: uint,
    reposter: principal,
  }
  {
    timestamp: uint,
    original-post-id: uint,
  }
)

;; Endorsement System
(define-map endorsements
  { endorsement-id: uint }
  {
    endorser: principal,
    endorsed: principal,
    skill-category: (string-ascii 32),
    message: (string-utf8 256),
    reputation-weight: uint,
    timestamp: uint,
    is-active: bool,
  }
)

;; Endorsement Relationship Tracking
(define-map user-endorsements
  {
    endorsed: principal,
    endorser: principal,
  }
  { endorsement-id: uint }
)

;; Reputation History Ledger
(define-map reputation-history
  {
    user: principal,
    timestamp: uint,
  }
  {
    action-type: (string-ascii 32),
    reputation-change: int,
    total-reputation: uint,
    details: (string-utf8 128),
  }
)

;; UTILITY FUNCTIONS

(define-private (get-current-time)
  stacks-block-height
)

(define-private (calculate-reputation-reward
    (likes uint)
    (author-reputation uint)
  )
  (let (
      (base-reward (if (> likes u0)
        (+ u10 (* likes u2))
        u0
      ))
      (reputation-multiplier (if (> author-reputation u500)
        u2
        u1
      ))
    )
    (* base-reward reputation-multiplier)
  )
)