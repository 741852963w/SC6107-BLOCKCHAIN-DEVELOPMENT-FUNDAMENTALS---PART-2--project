export default function DicePage() {
  return (
    <main>
      <section className="card">
        <h2>Dice</h2>
        <p className="muted">
          Contract path: <code>src/games/DiceGame.sol</code>
        </p>
        <p>
          Demo flow:
          <br />
          1) place bet with target range
          <br />
          2) request verifiable randomness
          <br />
          3) settle bet and transfer payout
        </p>
      </section>
    </main>
  );
}
