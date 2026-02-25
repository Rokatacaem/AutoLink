import '../Dashboard.css';

export default function MechanicsPage() {
    return (
        <div className="dashboard-container">
            <header className="dashboard-header">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <div>
                        <h1>Talleres Registrados</h1>
                        <p className="subtitle">Gestión de suscripciones y especialidades de la red</p>
                    </div>
                    <button className="btn-primary">+ Nuevo Taller</button>
                </div>
            </header>

            <section className="dashboard-grid">
                <div className="card" style={{ gridColumn: 'span 12' }}>
                    <table className="data-table">
                        <thead>
                            <tr>
                                <th>Propietario</th>
                                <th>Taller</th>
                                <th>Especialidades</th>
                                <th>Estado</th>
                                <th>Plan de Suscripción</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Carlos Díaz</td>
                                <td>Mecánica Carlos V</td>
                                <td>Mecánica General, Frenos</td>
                                <td><span className="badge success">ONLINE</span></td>
                                <td>BASIC ($10/mo)</td>
                                <td><button className="btn-text">Gestionar</button></td>
                            </tr>
                            <tr>
                                <td>Autorepair SPA</td>
                                <td>ElectroAuto Centro</td>
                                <td>Eléctrico</td>
                                <td><span className="badge warning">OFFLINE</span></td>
                                <td>PRO ($25/mo)</td>
                                <td><button className="btn-text">Gestionar</button></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    );
}
