"use client";

import { useEffect, useState } from 'react';
import '../Dashboard.css';

export default function OperationsPage() {
    const [isClient, setIsClient] = useState(false);

    useEffect(() => {
        setIsClient(true);
    }, []);

    return (
        <div className="dashboard-container">
            <header className="dashboard-header">
                <div>
                    <h1>Live Operations Map</h1>
                    <p className="subtitle">Visualización en tiempo real de Urgencias y Talleres (Mock)</p>
                </div>
            </header>

            <section className="dashboard-grid">
                <div className="card" style={{ gridColumn: 'span 12', height: '600px', display: 'flex', flexDirection: 'column' }}>
                    <div className="card-header">
                        <h2 className="card-title">📍 Radar Santiago</h2>
                        <div className="map-legend" style={{ display: 'flex', gap: '16px', fontSize: '0.9rem' }}>
                            <span style={{ color: '#FF453A' }}>🔴 Urgencia (Stranded)</span>
                            <span style={{ color: '#30D158' }}>🟢 Taller Online</span>
                            <span style={{ color: '#0A84FF' }}>🔵 Taller Asignado (En Ruta)</span>
                        </div>
                    </div>

                    {/* Placeholder Map Area */}
                    <div className="map-placeholder" style={{ flex: 1, backgroundColor: '#0A0A0A', borderRadius: '12px', border: '1px solid #2A2A2A', display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', gap: '16px' }}>
                        {isClient ? (
                            <div style={{ textAlign: 'center', color: '#A0A0A0' }}>
                                <p style={{ fontSize: '3rem', margin: '0 0 16px' }}>🗺️</p>
                                <p><b>Integración de Mapas Requerida</b></p>
                                <p style={{ fontSize: '0.9rem', maxWidth: '400px', margin: '8px auto' }}>Aquí se cargará Leaflet / Google Maps API mostrando las entidades en las coordenadas de la base de datos.</p>
                            </div>
                        ) : (
                            <p>Cargando radar...</p>
                        )}

                        {/* Mock Overlay Data */}
                        {isClient && (
                            <div style={{ position: 'absolute', bottom: '40px', right: '40px', background: 'rgba(20,20,20,0.9)', padding: '16px', borderRadius: '8px', border: '1px solid #333' }}>
                                <h4 style={{ marginBottom: '8px' }}>Tracking Activo</h4>
                                <ul style={{ listStyle: 'none', padding: 0, margin: 0, fontSize: '0.85rem' }}>
                                    <li style={{ marginBottom: '4px' }}>🔴 Conductor: -33.448,-70.669</li>
                                    <li style={{ marginBottom: '4px' }}>🔵 Mecánico V: -33.451,-70.660 (ETA: 4m)</li>
                                    <li>🟢 Taller SPA: -33.412,-70.620 (Libre)</li>
                                </ul>
                            </div>
                        )}
                    </div>
                </div>
            </section>
        </div>
    );
}
