from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas


def draw_slide(c: canvas.Canvas, title: str, bullets: list[str]) -> None:
    width, height = A4
    c.setFont("Helvetica-Bold", 24)
    c.drawString(48, height - 72, title)
    c.setFont("Helvetica", 13)
    y = height - 120
    for line in bullets:
        c.drawString(64, y, f"- {line}")
        y -= 26
    c.showPage()


def main() -> None:
    output = "docs/presentation-slides.pdf"
    c = canvas.Canvas(output, pagesize=A4)
    c.setTitle("SC6107 GameHub Presentation Slides")

    draw_slide(
        c,
        "Slide 1: Introduction",
        [
            "Project: Provably Fair On-Chain GameHub (Option 4)",
            "Problem: fair randomness in deterministic on-chain execution",
            "Team roles and contribution split across PR1-PR4",
        ],
    )
    draw_slide(
        c,
        "Slide 2: Architecture",
        [
            "Core: GameTreasury + VRFManager",
            "Games: RaffleGame + DiceGame",
            "Frontend routes: /, /raffle, /dice",
        ],
    )
    draw_slide(
        c,
        "Slide 3: Live Demo Flow",
        [
            "Wallet connect and dashboard entry",
            "Raffle enter -> randomness -> winner settlement",
            "Dice bet -> randomness -> payout settlement",
        ],
    )
    draw_slide(
        c,
        "Slide 4: Technical Deep Dive",
        [
            "Randomness callback pattern and request tracking",
            "Treasury-based payout isolation",
            "Security and gas optimization strategy",
        ],
    )
    draw_slide(
        c,
        "Slide 5: Results and Reflection",
        [
            "Testing strategy: unit + staging/integration + fuzz/invariant plan",
            "Security/gas evidence package in docs/",
            "Known limitations and future improvements",
        ],
    )

    c.save()


if __name__ == "__main__":
    main()
