# TabL: Pull Request

---

## 1. Summary
*Provide a clear and concise summary of what this PR adds, fixes, or changes. Explain the "what" and the "why" of your changes.*

> **Example:**
> This PR implements the new `WalletBloc` and integrates it with the profile screen. This allows users to view their current token balance from the internal ledger. It addresses ticket `PROJ-123`.

---

## 2. Related Issue(s)
*If this PR closes or is related to any open issues, please link them here.*

-   Closes #<issue_number>
-   Related to #<issue_number>

---

## 3. The Test Plan
*Describe the testing you have done to ensure your changes work correctly and do not break existing functionality. This is a critical step.*

-   [ ] I have added new unit tests for my BLoC/repository.
-   [ ] I have added new widget tests for my UI components.
-   [ ] All existing tests pass successfully with my changes (`flutter test`).
-   [ ] I have manually tested the following scenarios:
    1.  *Scenario A: Verified that the wallet balance updates after a successful transaction.*
    2.  *Scenario B: Checked for correct error handling when the API returns a failure.*
    3.  *Scenario C: Confirmed the UI looks correct on both small and large screen sizes.*

---

## 4. UI Changes & Screenshots
*If your changes affect the UI, please provide "before" and "after" screenshots or a short GIF. This is the fastest way for a reviewer to understand your changes.*

| Before | After |
| :----: | :---: |
|        |       |

---

## 5. Checklist for the Author

-   [ ] My code follows the project's **[Contribution Guidelines](./Contribution.md)**.
-   [ ] I have performed a self-review of my own code.
-   [ ] I have commented on my code, particularly in hard-to-understand areas.
-   [ ] My changes generate no new warnings or errors (`flutter analyze`).
-   [ ] I have added tests that prove my fix is effective or that my feature works.
-   [ ] I have updated the documentation where necessary.

---

## 6. Notes for the Reviewer
*Is there anything specific you want the reviewer to pay close attention to? Are there any trade-offs you made or future improvements you're planning?*
