📖 On-chain Storytelling DAO

A decentralized autonomous organization (DAO) for collaborative storytelling on the Stacks blockchain. Writers can propose new chapters, the community votes on them, and approved chapters become a permanent part of the on-chain story.

🚀 Features

Propose Chapters: Writers submit story chapters as proposals.

Community Voting: Token holders or participants cast votes for or against a chapter.

Execution: If a proposal passes with sufficient votes and majority approval, it is added to the permanent on-chain story.

Immutable Story History: All approved chapters are stored forever on-chain with author attribution and block height.

DAO Governance Parameters: The contract owner can adjust voting periods and minimum vote requirements.

📂 Data Structures
Chapters

Stores finalized story chapters:

content: The text of the chapter (string-ascii 2000)

author: Principal of the proposer

block-height: When the chapter was added

proposal-id: Link to the proposal that passed

Proposals

Tracks active/ended chapter proposals:

chapter-content: Proposed story text

proposer: Address of the proposer

votes-for / votes-against: Community voting tallies

end-block: Block height when voting closes

executed: Whether the proposal has been finalized

Votes

Prevents double voting by recording each (proposal-id, voter) pair.

⚙️ Functions
Chapter Management

propose-chapter(content) → Submit a new story chapter proposal.

vote-on-proposal(proposal-id, vote-for) → Cast a vote (for or against).

execute-proposal(proposal-id) → Finalize a proposal if voting is complete and successful.

Read-Only Queries

get-chapter(chapter-id) → Retrieve a specific chapter.

get-proposal(proposal-id) → Retrieve details of a proposal.

get-vote(proposal-id, voter) → Check if a voter already voted.

get-total-chapters() → Get total approved chapters.

get-story-so-far() → Return the full on-chain story.

get-chapters-range(start, end) → Retrieve a range of chapters.

Admin Functions

set-voting-period(new-period) → Update voting period length.

set-min-votes(new-min) → Update minimum votes required for approval.

✅ Example Workflow

A writer calls propose-chapter("Once upon a time...").

Community members vote using vote-on-proposal.

After voting ends, execute-proposal finalizes and adds the chapter if approved.

The chapter becomes part of the on-chain story, retrievable via get-story-so-far.

🔐 Error Codes

ERR_UNAUTHORIZED (u100) → Action not permitted.

ERR_PROPOSAL_NOT_FOUND (u101) → Proposal ID invalid.

ERR_VOTING_ENDED (u102) → Voting already closed.

ERR_ALREADY_VOTED (u103) → Voter has already voted.

ERR_INSUFFICIENT_VOTES (u104) → Proposal didn’t meet requirements.

🌍 Vision

The On-chain Storytelling DAO allows communities to co-create literature, lore, or collaborative narratives in a trustless and transparent way. Every word that passes consensus becomes part of a permanent blockchain-backed cultural artifact.

📜 License

MIT License – free to use, modify, and build upon.