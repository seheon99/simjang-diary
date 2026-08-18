@main
struct RetellingTextCheck {
    static func main() {
        // Strips a trailing chat-template stop token.
        assert(RetellingText.sanitize("월세 인상 통보를 받았다.<|eot_id|>") == "월세 인상 통보를 받았다.")
        // Trims surrounding whitespace and newlines.
        assert(RetellingText.sanitize("  고양이가 아파 병원에 갔다.  \n") == "고양이가 아파 병원에 갔다.")
        // Strips leading and trailing tokens together.
        assert(RetellingText.sanitize("<|begin_of_text|>운동을 시작했다.<|eot_id|>") == "운동을 시작했다.")
        // Leaves clean text untouched.
        assert(RetellingText.sanitize("평범한 하루였다.") == "평범한 하루였다.")
        // Token-only output reduces to empty, which callers treat as failure.
        assert(RetellingText.sanitize("<|eot_id|>") == "")
        assert(RetellingText.sanitize("") == "")
        print("RetellingText: all checks passed")
    }
}
