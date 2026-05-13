export default function RafflePage() {
  return (
    <main>
      <section className="card">
        <h2>Raffle</h2>
        <p className="muted">
          Contract path: <code>src/games/RaffleGame.sol</code>
        </p>
        <p>
          Demo flow:
          <br />
          1) enter raffle
          <br />
          2) request randomness
          <br />
          3) settle winner and payout from treasury
        </p>
      </section>
    </main>
  );
}
