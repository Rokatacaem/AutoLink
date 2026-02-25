import '../Dashboard.css';

export default function TransactionsPage() {
    return (
        <div className="dashboard-container">
            <header className="dashboard-header">
                <div>
                    <h1>Módulo Financiero</h1>
                    <p className="subtitle">Gestión de Retenciones y Liquidaciones (Mercado Pago)</p>
                </div>
            </header>

            <section className="dashboard-grid">
                <div className="card" style={{ gridColumn: 'span 12' }}>
                    <div className="card-header">
                        <h2 className="card-title">Transacciones Recientes</h2>
                        <div style={{ display: 'flex', gap: '8px' }}>
                            <select className="filter-select">
                                <option value="ALL">Todos los estados</option>
                                <option value="PAID">Cobrado (PAID)</option>
                                <option value="DISBURSED">Liquidado (DISBURSED)</option>
                                <option value="REFUNDED">Reembolsado (REFUNDED)</option>
                            </select>
                        </div>
                    </div>
                    <table className="data-table">
                        <thead>
                            <tr>
                                <th>ID Transacción</th>
                                <th>Service Request</th>
                                <th>Monto (CLP)</th>
                                <th>Estado</th>
                                <th>Gateway</th>
                                <th>Fecha</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>TX-99824</td>
                                <td>#SR-1040</td>
                                <td>$ 45,000</td>
                                <td><span className="badge success">DISBURSED</span></td>
                                <td>Mercado Pago</td>
                                <td>24 Feb, 14:30</td>
                                <td><button className="btn-text" disabled>Liquidado</button></td>
                            </tr>
                            <tr>
                                <td>TX-99825</td>
                                <td>#SR-1041</td>
                                <td>$ 28,500</td>
                                <td><span className="badge info">PAID</span></td>
                                <td>Mercado Pago</td>
                                <td>24 Feb, 15:15</td>
                                <td><button className="btn-text">Liquidar a Taller</button></td>
                            </tr>
                            <tr>
                                <td>TX-99826</td>
                                <td>#SR-1042</td>
                                <td>$ 15,000</td>
                                <td><span className="badge warning">PENDING</span></td>
                                <td>Transferencia</td>
                                <td>24 Feb, 16:00</td>
                                <td>--</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    );
}
