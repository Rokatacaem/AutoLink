import './Dashboard.css';

export default function Home() {
  return (
    <div className="dashboard-container">
      <header className="dashboard-header">
        <div>
          <h1>Resumen Operativo</h1>
          <p className="subtitle">Métricas en vivo de la red AutoLink hoy.</p>
        </div>
      </header>

      <section className="dashboard-grid">
        {/* KPI Cards */}
        <div className="card kpi-card">
          <span className="kpi-title">Urgencias Activas</span>
          <span className="kpi-value text-accent">14</span>
          <span className="kpi-trend positive">↑ 12% vs ayer</span>
        </div>
        <div className="card kpi-card">
          <span className="kpi-title">Talleres Online</span>
          <span className="kpi-value text-success">38</span>
          <span className="kpi-trend">Estable</span>
        </div>
        <div className="card kpi-card">
          <span className="kpi-title">Ingresos Retenidos (Hoy)</span>
          <span className="kpi-value">$4,250</span>
          <span className="kpi-trend positive">↑ 8% vs ayer</span>
        </div>

        {/* Gemini AI Analytics */}
        <div className="card ai-analytics-card">
          <div className="card-header">
            <h2 className="card-title">✨ Tendencias de Fallas (Gemini AI)</h2>
          </div>
          <div className="ai-stats-list">
            <div className="ai-stat-item">
              <span className="ai-stat-label">Batería Descargada (Invierno)</span>
              <div className="progress-bar"><div className="progress-fill" style={{ width: '45%' }}></div></div>
              <span className="ai-stat-percent">45%</span>
            </div>
            <div className="ai-stat-item">
              <span className="ai-stat-label">Rotura de Correa de Distribución</span>
              <div className="progress-bar"><div className="progress-fill" style={{ width: '25%' }}></div></div>
              <span className="ai-stat-percent">25%</span>
            </div>
            <div className="ai-stat-item">
              <span className="ai-stat-label">Sobrecalentamiento de Motor</span>
              <div className="progress-bar"><div className="progress-fill" style={{ width: '15%' }}></div></div>
              <span className="ai-stat-percent">15%</span>
            </div>
            <div className="ai-stat-item">
              <span className="ai-stat-label">Otros (Frenos, Neumáticos)</span>
              <div className="progress-bar"><div className="progress-fill" style={{ width: '15%' }}></div></div>
              <span className="ai-stat-percent">15%</span>
            </div>
          </div>
          <p className="ai-insight">
            <strong>Insight:</strong> Las fallas eléctricas han aumentado un 30% esta semana. Se recomienda notificar a los talleres especializados en electricidad automotriz.
          </p>
        </div>

        {/* Recent Activity */}
        <div className="card recent-activity-card">
          <div className="card-header">
            <h2 className="card-title">Urgencias Recientes</h2>
            <button className="btn-text">Ver todas</button>
          </div>
          <table className="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Cliente</th>
                <th>Especialidad</th>
                <th>Estado</th>
                <th>ETA</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>#SR-1042</td>
                <td>Juan Pérez</td>
                <td>Mecánica General</td>
                <td><span className="badge warning">PENDING</span></td>
                <td>--</td>
              </tr>
              <tr>
                <td>#SR-1041</td>
                <td>María Gómez</td>
                <td>Eléctrico</td>
                <td><span className="badge info">ACCEPTED</span></td>
                <td>8 min</td>
              </tr>
              <tr>
                <td>#SR-1040</td>
                <td>Carlos Saavedra</td>
                <td>Neumáticos</td>
                <td><span className="badge success">COMPLETED</span></td>
                <td>Llegó</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
