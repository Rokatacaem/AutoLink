"use client";

/**
 * LiveMap — Mapa de Operaciones en Tiempo Real
 *
 * Muestra mecánicos (ONLINE/OFFLINE) y urgencias activas usando Leaflet.js.
 * Polling cada 15 segundos al endpoint /api/v1/admin/map-data.
 * Filtro por comuna: centra el mapa en Santiago Centro o San Bernardo.
 */

/* eslint-disable @typescript-eslint/no-explicit-any */

import { useEffect, useRef, useState, useCallback } from "react";
import "./LiveMap.css";

// ── Tipos ──────────────────────────────────────────────────────────────────────
interface MechanicFeature {
    id: number;
    name: string;
    lat: number | null;
    lng: number | null;
    status: "ONLINE" | "OFFLINE";
    reputation_score: number;
}

interface RequestFeature {
    id: number;
    customer_name: string;
    lat: number | null;
    lng: number | null;
    diagnosis: string;
    service_status: string;
}

interface MapData {
    mechanics: MechanicFeature[];
    active_requests: RequestFeature[];
}

// ── Comunas predefinidas ───────────────────────────────────────────────────────
const COMMUNES: Record<string, [number, number]> = {
    "Santiago Centro": [-33.4489, -70.6693],
    "San Bernardo": [-33.5928, -70.6989],
    "Providencia": [-33.4326, -70.6345],
    "Maipú": [-33.5113, -70.7578],
};

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "https://auto-link-steel.vercel.app";
const POLL_INTERVAL = 15_000;

// ── Componente ─────────────────────────────────────────────────────────────────
export default function LiveMap() {
    const mapContainerRef = useRef<HTMLDivElement>(null);
    const mapRef = useRef<any>(null);
    const leafletRef = useRef<any>(null);      // Almacena instancia de L para reusar
    const markersGroupRef = useRef<any>(null);
    const requestMarkersRef = useRef<any>(null);
    const timerRef = useRef<ReturnType<typeof setInterval>>();

    const [mapData, setMapData] = useState<MapData>({ mechanics: [], active_requests: [] });
    const [lastUpdate, setLastUpdate] = useState<Date | null>(null);
    const [activeCommune, setActiveCommune] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    // ── Fetch datos del endpoint ───────────────────────────────────────────────
    const fetchMapData = useCallback(async () => {
        try {
            const res = await fetch(`${API_URL}/api/v1/admin/map-data`, {
                cache: "no-store",
            });
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            const data: MapData = await res.json();
            setMapData(data);
            setLastUpdate(new Date());
            setIsLoading(false);
        } catch (err) {
            console.warn("LiveMap: Error fetching map data", err);
            setIsLoading(false);
        }
    }, []);

    // ── Inicializar Leaflet (solo en cliente) ──────────────────────────────────
    useEffect(() => {
        if (!mapContainerRef.current || mapRef.current) return;

        const initMap = async () => {
            const L = (await import("leaflet")).default;
            // Importar CSS de Leaflet dinámicamente
            await import("leaflet/dist/leaflet.css" as string);

            // Guardar referencia
            leafletRef.current = L;

            // Fix default icons que webpack rompe
            delete (L.Icon.Default.prototype as any)._getIconUrl;
            L.Icon.Default.mergeOptions({
                iconRetinaUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
                iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
                shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
            });

            // Centro inicial: Santiago
            const map = L.map(mapContainerRef.current!, {
                center: [-33.4489, -70.6693],
                zoom: 12,
                zoomControl: true,
            });

            // Tile layer oscuro (CartoDB Dark — OpenStreetMap sin API key)
            L.tileLayer(
                "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                {
                    attribution: "© OpenStreetMap contributors © CARTO",
                    maxZoom: 19,
                }
            ).addTo(map);

            // Grupos de marcadores
            markersGroupRef.current = L.layerGroup().addTo(map);
            requestMarkersRef.current = L.layerGroup().addTo(map);

            mapRef.current = map;

            // Fetch inicial
            await fetchMapData();
        };

        initMap();

        // Polling cada 15 segundos
        timerRef.current = setInterval(() => {
            fetchMapData();
        }, POLL_INTERVAL);

        return () => {
            clearInterval(timerRef.current);
            if (mapRef.current) {
                mapRef.current.remove();
                mapRef.current = null;
            }
        };
    }, [fetchMapData]);

    // ── Redibujar marcadores cuando cambia mapData ─────────────────────────────
    useEffect(() => {
        const L = leafletRef.current;
        if (!L || !mapRef.current) return;

        // ── Mecánicos ────────────────────────────────────────────────────────────
        if (markersGroupRef.current) {
            markersGroupRef.current.clearLayers();

            mapData.mechanics.forEach((m) => {
                if (m.lat == null || m.lng == null) return;

                const color = m.status === "ONLINE" ? "#30D158" : "#555";
                const opacity = m.status === "ONLINE" ? "1" : "0.5";
                const icon = L.divIcon({
                    className: "",
                    html: `<div style="width:14px;height:14px;border-radius:50%;background:${color};border:2px solid #fff;box-shadow:0 0 6px ${color};opacity:${opacity}"></div>`,
                    iconSize: [14, 14],
                    iconAnchor: [7, 7],
                });

                const marker = L.marker([m.lat, m.lng], { icon });
                marker.bindPopup(`
          <div class="popup-title">🔧 ${m.name}</div>
          <div class="popup-meta">
            Estado: <b style="color:${color}">${m.status}</b><br/>
            Lat: ${m.lat.toFixed(4)}, Lng: ${m.lng.toFixed(4)}
          </div>
          <span class="popup-score">⭐ ${m.reputation_score.toFixed(1)} / 10</span>
        `);
                (markersGroupRef.current as any).addLayer(marker);
            });
        }

        // ── Urgencias activas ─────────────────────────────────────────────────────
        if (requestMarkersRef.current) {
            requestMarkersRef.current.clearLayers();

            mapData.active_requests.forEach((r) => {
                if (r.lat == null || r.lng == null) return;

                const icon = L.divIcon({
                    className: "marker-urgency",
                    html: `<div style="width:16px;height:16px;border-radius:50%;background:#FF453A;border:2px solid #fff;box-shadow:0 0 8px #FF453A"></div>`,
                    iconSize: [16, 16],
                    iconAnchor: [8, 8],
                });

                const marker = L.marker([r.lat, r.lng], { icon });
                marker.bindPopup(`
          <div class="popup-title">🚨 ${r.customer_name}</div>
          <div class="popup-meta">
            ${r.diagnosis}<br/>
            Estado: <b>${r.service_status}</b>
          </div>
        `);
                (requestMarkersRef.current as any).addLayer(marker);
            });
        }
    }, [mapData]);

    // ── Centrar mapa por comuna ────────────────────────────────────────────────
    const centerOnCommune = (name: string) => {
        if (!mapRef.current) return;
        const coords = COMMUNES[name];
        if (!coords) return;
        (mapRef.current as any).setView(coords, 14, { animate: true });
        setActiveCommune(name);
    };

    // ── Stats ─────────────────────────────────────────────────────────────────
    const onlineMechanics = mapData.mechanics.filter((m) => m.status === "ONLINE").length;
    const offlineMechanics = mapData.mechanics.filter((m) => m.status === "OFFLINE").length;

    return (
        <div className="livemap-wrapper">
            {/* Filtro por comuna */}
            <div className="livemap-controls">
                {Object.keys(COMMUNES).map((name) => (
                    <button
                        key={name}
                        className={`livemap-btn${activeCommune === name ? " active" : ""}`}
                        onClick={() => centerOnCommune(name)}
                    >
                        📍 {name}
                    </button>
                ))}
            </div>

            {/* Contenedor del mapa */}
            <div ref={mapContainerRef} className="livemap-canvas" />

            {/* HUD de estado */}
            <div className="livemap-hud">
                <h4>
                    <span className="livemap-pulse-dot" />
                    En Vivo
                </h4>
                <div className="livemap-hud-row">
                    <span>Talleres Online</span>
                    <span className="livemap-hud-badge badge-green">{onlineMechanics}</span>
                </div>
                <div className="livemap-hud-row">
                    <span>Talleres Offline</span>
                    <span className="livemap-hud-badge livemap-muted">{offlineMechanics}</span>
                </div>
                <div className="livemap-hud-row">
                    <span>Urgencias Activas</span>
                    <span className="livemap-hud-badge badge-red">
                        {mapData.active_requests.length}
                    </span>
                </div>
                {lastUpdate && (
                    <p className="livemap-timestamp">
                        Actualizado: {lastUpdate.toLocaleTimeString("es-CL")}
                    </p>
                )}
                {isLoading && (
                    <p className="livemap-timestamp">Cargando datos...</p>
                )}
            </div>
        </div>
    );
}
