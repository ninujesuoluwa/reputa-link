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

(define-private (calculate-endorsement-weight (endorser-reputation uint))
  (if (>= endorser-reputation u1000)
    u50
    (if (>= endorser-reputation u500)
      u30
      (if (>= endorser-reputation u100)
        u20
        u10
      )
    )
  )
)

;; INPUT VALIDATION FUNCTIONS

(define-private (is-valid-string-ascii (input (string-ascii 32)))
  (and (> (len input) u0) (<= (len input) u32))
)

(define-private (is-valid-string-utf8-256 (input (string-utf8 256)))
  (<= (len input) u256)
)

(define-private (is-valid-string-utf8-512 (input (string-utf8 512)))
  (and (> (len input) u0) (<= (len input) u512))
)

(define-private (is-valid-tag-list (tags (list 5 (string-ascii 32))))
  (fold check-tag-validity tags true)
)

(define-private (check-tag-validity
    (tag (string-ascii 32))
    (acc bool)
  )
  (and acc (<= (len tag) u32))
)

;; DATA SANITIZATION FUNCTIONS

(define-private (sanitize-bio (bio (string-utf8 256)))
  (if (is-valid-string-utf8-256 bio)
    bio
    u""
  )
)

(define-private (sanitize-message (message (string-utf8 256)))
  (if (is-valid-string-utf8-256 message)
    message
    u""
  )
)

(define-private (verify-user-internal
    (user-address principal)
    (user-data {
      user-id: uint,
      username: (string-ascii 32),
      bio: (string-utf8 256),
      reputation-score: uint,
      total-posts: uint,
      total-likes-received: uint,
      total-endorsements-received: uint,
      joined-at: uint,
      is-verified: bool,
    })
  )
  (map-set users { user-address: user-address }
    (merge user-data { is-verified: true })
  )
)

;; READ-ONLY QUERY FUNCTIONS

(define-read-only (get-user (user-address principal))
  (map-get? users { user-address: user-address })
)

(define-read-only (get-user-by-id (user-id uint))
  (match (map-get? user-by-id { user-id: user-id })
    user-data (get-user (get user-address user-data))
    none
  )
)

(define-read-only (get-post (post-id uint))
  (map-get? posts { post-id: post-id })
)

(define-read-only (get-endorsement (endorsement-id uint))
  (map-get? endorsements { endorsement-id: endorsement-id })
)

(define-read-only (has-liked-post
    (post-id uint)
    (user principal)
  )
  (is-some (map-get? post-likes {
    post-id: post-id,
    liker: user,
  }))
)

(define-read-only (has-endorsed-user
    (endorser principal)
    (endorsed principal)
  )
  (is-some (map-get? user-endorsements {
    endorsed: endorsed,
    endorser: endorser,
  }))
)

(define-read-only (get-user-reputation (user-address principal))
  (match (get-user user-address)
    user-data (get reputation-score user-data)
    u0
  )
)

(define-read-only (get-platform-stats)
  {
    total-users: (- (var-get next-user-id) u1),
    total-posts: (- (var-get next-post-id) u1),
    total-endorsements: (- (var-get next-endorsement-id) u1),
    platform-fee: (var-get platform-fee),
    min-reputation-for-rewards: (var-get min-reputation-for-rewards),
  }
)

;; USER MANAGEMENT FUNCTIONS

(define-public (register-user
    (username (string-ascii 32))
    (bio (string-utf8 256))
  )
  (let (
      (current-user-id (var-get next-user-id))
      (current-time (get-current-time))
      (sanitized-bio (sanitize-bio bio))
    )
    (asserts! (is-none (get-user tx-sender)) err-already-exists)
    (asserts! (is-valid-string-ascii username) err-invalid-input)
    (asserts! (is-valid-string-utf8-256 bio) err-invalid-input)
    (map-set users { user-address: tx-sender } {
      user-id: current-user-id,
      username: username,
      bio: sanitized-bio,
      reputation-score: u50, ;; Starting reputation
      total-posts: u0,
      total-likes-received: u0,
      total-endorsements-received: u0,
      joined-at: current-time,
      is-verified: false,
    })
    (map-set user-by-id { user-id: current-user-id } { user-address: tx-sender })
    (var-set next-user-id (+ current-user-id u1))
    (ok current-user-id)
  )
)

(define-public (update-profile
    (username (string-ascii 32))
    (bio (string-utf8 256))
  )
  (let (
      (user-data (unwrap! (get-user tx-sender) err-not-found))
      (sanitized-bio (sanitize-bio bio))
    )
    (asserts! (is-valid-string-ascii username) err-invalid-input)
    (asserts! (is-valid-string-utf8-256 bio) err-invalid-input)
    (map-set users { user-address: tx-sender }
      (merge user-data {
        username: username,
        bio: sanitized-bio,
      })
    )
    (ok true)
  )
)

;; CONTENT CREATION & INTERACTION FUNCTIONS

(define-public (create-post
    (content (string-utf8 512))
    (tags (list 5 (string-ascii 32)))
  )
  (let (
      (current-post-id (var-get next-post-id))
      (current-time (get-current-time))
      (user-data (unwrap! (get-user tx-sender) err-not-found))
    )
    (asserts! (is-valid-string-utf8-512 content) err-invalid-input)
    (asserts! (is-valid-tag-list tags) err-invalid-input)
    ;; Create post
    (map-set posts { post-id: current-post-id } {
      author: tx-sender,
      content: content,
      timestamp: current-time,
      likes: u0,
      reposts: u0,
      replies: u0,
      reputation-earned: u0,
      is-active: true,
      tags: tags,
    })
    ;; Update user stats
    (map-set users { user-address: tx-sender }
      (merge user-data { total-posts: (+ (get total-posts user-data) u1) })
    )
    (var-set next-post-id (+ current-post-id u1))
    (ok current-post-id)
  )
)

(define-public (like-post (post-id uint))
  (let (
      (post-data (unwrap! (get-post post-id) err-not-found))
      (current-time (get-current-time))
      (author (get author post-data))
      (author-data (unwrap! (get-user author) err-not-found))
    )
    (asserts! (get is-active post-data) err-not-found)
    (asserts! (not (has-liked-post post-id tx-sender)) err-already-exists)
    (asserts! (not (is-eq tx-sender author)) err-self-endorsement)
    ;; Record the like
    (map-set post-likes {
      post-id: post-id,
      liker: tx-sender,
    } { timestamp: current-time }
    )
    ;; Update post stats and calculate rewards
    (let (
        (new-likes (+ (get likes post-data) u1))
        (reputation-reward (calculate-reputation-reward new-likes (get reputation-score author-data)))
      )
      (map-set posts { post-id: post-id }
        (merge post-data {
          likes: new-likes,
          reputation-earned: (+ (get reputation-earned post-data) reputation-reward),
        })
      )
      ;; Update author's reputation and engagement stats
      (map-set users { user-address: author }
        (merge author-data {
          reputation-score: (+ (get reputation-score author-data) reputation-reward),
          total-likes-received: (+ (get total-likes-received author-data) u1),
        })
      )
    )
    (ok true)
  )
)

(define-public (repost
    (post-id uint)
    (original-post-id uint)
  )
  (let (
      (post-data (unwrap! (get-post post-id) err-not-found))
      (original-post-data (unwrap! (get-post original-post-id) err-not-found))
      (current-time (get-current-time))
    )
    (asserts! (get is-active post-data) err-not-found)
    (asserts! (get is-active original-post-data) err-not-found)
    (asserts! (not (is-eq tx-sender (get author post-data))) err-self-endorsement)
    ;; Record the repost
    (map-set post-reposts {
      post-id: post-id,
      reposter: tx-sender,
    } {
      timestamp: current-time,
      original-post-id: original-post-id,
    })
    ;; Update post engagement metrics
    (map-set posts { post-id: post-id }
      (merge post-data { reposts: (+ (get reposts post-data) u1) })
    )
    (ok true)
  )
)

;; PEER ENDORSEMENT SYSTEM

(define-public (endorse-user
    (endorsed-user principal)
    (skill-category (string-ascii 32))
    (message (string-utf8 256))
  )
  (let (
      (current-endorsement-id (var-get next-endorsement-id))
      (current-time (get-current-time))
      (endorser-data (unwrap! (get-user tx-sender) err-not-found))
      (endorsed-data (unwrap! (get-user endorsed-user) err-not-found))
      (endorser-reputation (get reputation-score endorser-data))
      (sanitized-message (sanitize-message message))
    )
    (asserts! (not (is-eq tx-sender endorsed-user)) err-self-endorsement)
    (asserts! (>= endorser-reputation u50) err-insufficient-reputation)
    (asserts! (not (has-endorsed-user tx-sender endorsed-user))
      err-already-endorsed
    )
    (asserts! (is-valid-string-ascii skill-category) err-invalid-input)
    (asserts! (is-valid-string-utf8-256 message) err-invalid-input)
    (let ((reputation-weight (calculate-endorsement-weight endorser-reputation)))
      ;; Create endorsement record
      (map-set endorsements { endorsement-id: current-endorsement-id } {
        endorser: tx-sender,
        endorsed: endorsed-user,
        skill-category: skill-category,
        message: sanitized-message,
        reputation-weight: reputation-weight,
        timestamp: current-time,
        is-active: true,
      })
      ;; Track endorsement relationship
      (map-set user-endorsements {
        endorsed: endorsed-user,
        endorser: tx-sender,
      } { endorsement-id: current-endorsement-id }
      )
      ;; Update endorsed user's reputation and endorsement count
      (map-set users { user-address: endorsed-user }
        (merge endorsed-data {
          reputation-score: (+ (get reputation-score endorsed-data) reputation-weight),
          total-endorsements-received: (+ (get total-endorsements-received endorsed-data) u1),
        })
      )
      (var-set next-endorsement-id (+ current-endorsement-id u1))
      (ok current-endorsement-id)
    )
  )
)

;; ADMINISTRATIVE FUNCTIONS

(define-public (verify-user (user-address principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (match (get-user user-address)
      user-data (begin
        (verify-user-internal user-address user-data)
        (ok true)
      )
      err-not-found
    )
  )
)

(define-public (update-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee u1000) err-invalid-input) ;; Maximum 10% fee
    (var-set platform-fee new-fee)
    (ok true)
  )
)

(define-public (update-min-reputation-for-rewards (new-min uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-min u10000) err-invalid-input) ;; Reasonable maximum limit
    (var-set min-reputation-for-rewards new-min)
    (ok true)
  )
)

;; CONTENT MODERATION FUNCTIONS

(define-public (deactivate-post (post-id uint))
  (let ((post-data (unwrap! (get-post post-id) err-not-found)))
    (asserts!
      (or (is-eq tx-sender contract-owner) (is-eq tx-sender (get author post-data)))
      err-unauthorized
    )
    (map-set posts { post-id: post-id } (merge post-data { is-active: false }))
    (ok true)
  )
)

(define-public (deactivate-endorsement (endorsement-id uint))
  (let ((endorsement-data (unwrap! (get-endorsement endorsement-id) err-not-found)))
    (asserts!
      (or (is-eq tx-sender contract-owner) (is-eq tx-sender (get endorser endorsement-data)))
      err-unauthorized
    )
    (map-set endorsements { endorsement-id: endorsement-id }
      (merge endorsement-data { is-active: false })
    )
    (ok true)
  )
)
