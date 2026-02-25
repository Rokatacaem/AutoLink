import Link from 'next/link';
import './Sidebar.css';

export default function Sidebar() {
    return (
        <aside className="sidebar">
            <div className="sidebar-header">
                <div className="logo-container">
                    <span className="logo-icon">▲</span>
                    <span className="logo-text">AutoLink <span className="logo-badge">WOR</span></span>
                </div>
            </div>

            <nav className="sidebar-nav">
                <Link href="/" className="nav-item active">
                    <span className="nav-icon">📊</span>
                    Overview
                </Link>
                <Link href="/operations" className="nav-item">
                    <span className="nav-icon">🗺️</span>
                    Live Ops Map
                </Link>
                <Link href="/transactions" className="nav-item">
                    <span className="nav-icon">💳</span>
                    Financials
                </Link>
                <Link href="/mechanics" className="nav-item">
                    <span className="nav-icon">🔧</span>
                    Talleres
                </Link>
            </nav>

            <div className="sidebar-footer">
                <div className="user-profile">
                    <div className="avatar">A</div>
                    <div className="user-info">
                        <span className="user-name">Admin</span>
                        <span className="user-role">Superuser</span>
                    </div>
                </div>
            </div>
        </aside>
    );
}
