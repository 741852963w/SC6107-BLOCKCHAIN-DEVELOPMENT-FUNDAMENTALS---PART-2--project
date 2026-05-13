export default function DashboardPage() {
  return (
    <main>
      <section className="card">
        <h2>Project Dashboard</h2>
        <p className="muted">
          This lightweight frontend is included to satisfy SC6107 submission packaging and demo routing.
        </p>
      </section>

      <section className="card">
        <h3>Implemented Games</h3>
        <ul>
          <li>Raffle game with time-based draw flow</li>
          <li>Dice game with random-result settlement flow</li>
        </ul>
      </section>
    </main>
  );
}
