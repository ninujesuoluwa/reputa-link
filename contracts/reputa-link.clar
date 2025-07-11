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