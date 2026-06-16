import Testing
@testable import BudgetLeagueTracker

@Suite("PodLayoutHint")
struct PodLayoutHintTests {
    @Test("nil when count is multiple of pod size")
    func evenCount() {
        #expect(PodLayoutHint.message(presentCount: 4) == nil)
        #expect(PodLayoutHint.message(presentCount: 8) == nil)
    }

    @Test("remainder only when fewer than pod size")
    func smallGroup() {
        #expect(PodLayoutHint.message(presentCount: 3) == "3 present — pods will seat 3 players.")
    }

    @Test("full pods plus remainder")
    func mixedPods() {
        #expect(
            PodLayoutHint.message(presentCount: 5)
                == "5 present — expect 1 pod of 4 and 1 pod of 1."
        )
        #expect(
            PodLayoutHint.message(presentCount: 7)
                == "7 present — expect 1 pod of 4 and 1 pod of 3."
        )
    }
}
