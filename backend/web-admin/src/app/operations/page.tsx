"use client";

import dynamic from "next/dynamic";
import "../Dashboard.css";

// Leaflet no soporta SSR — carga únicamente en cliente
const LiveMap = dynamic(() => import("../../components/LiveMap"), {
    ssr: false,
    loading: () => (
        <div style={{
            height: "100%",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            color: "#555",
            flexDirection: "column",
            gap: "12px",
        }}>
            <span style={{ fontSize: "2rem" }}>🗺️</span>
            <span>Cargando radar...</span>
        </div>
    ),
});

export default function OperationsPage() {
    return (
        <div className="dashboard-container">
            <header className="dashboard-header">
                <div>
                    <h1>Live Operations Map</h1>
                    <p className="subtitle">Visualización en tiempo real · Actualización automática cada 15s</p>
                </div>
                <div style={{ display: "flex", gap: "16px", fontSize: "0.85rem", alignItems: "center" }}>
                    <span style={{ color: "#FF453A" }}>🔴 Urgencia</span>
                    <span style={{ color: "#30D158" }}>🟢 Taller Online</span>
                    <span style={{ color: "#555" }}>⚫ Taller Offline</span>
                </div>
            </header>

            <section className="dashboard-grid">
                <div
                    className="card"
                    style={{ gridColumn: "span 12", height: "620px", display: "flex", flexDirection: "column" }}
                >
                    <div className="card-header">
                        <h2 className="card-title">📍 Radar Santiago</h2>
                    </div>
                    <div style={{ flex: 1, position: "relative", borderRadius: "12px", overflow: "hidden" }}>
                        <LiveMap />
                    </div>
                </div>
            </section>
        </div>
    );
}
