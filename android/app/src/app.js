import { useState } from 'react';
import Login from './pages/Login';
import Sidebar from './components/layout/Sidebar';
import Topbar from './components/layout/Topbar';
import { ToastProvider } from './components/ui';

import Dashboard     from './pages/Dashboard';
import Features      from './pages/Features';
import Orders        from './pages/Orders';
import Grocery       from './pages/Grocery';
import Movies        from './pages/Movies';
import Hotels        from './pages/Hotels';
import Rides         from './pages/Rides';
import Bikes         from './pages/Bikes';
import Travel        from './pages/Travel';
import Trains        from './pages/Trains';
import Medicine      from './pages/Medicine';
import Leisure       from './pages/Leisure';
import Restaurants   from './pages/Restaurants';
import Users         from './pages/Users';
import Drivers       from './pages/Drivers';
import Offers        from './pages/Offers';
import Wallet        from './pages/Wallet';
import Notifications from './pages/Notifications';
import Chat          from './pages/Chat';
import Settings      from './pages/Settings';

import './styles/globals.css';
import './App.css';

const PAGES = {
  dashboard: Dashboard, features: Features,
  orders: Orders, grocery: Grocery, movies: Movies,
  hotels: Hotels, rides: Rides, bikes: Bikes,
  travel: Travel, trains: Trains, medicine: Medicine,
  leisure: Leisure, restaurants: Restaurants,
  users: Users, drivers: Drivers, offers: Offers,
  wallet: Wallet, notifications: Notifications,
  chat: Chat, settings: Settings,
};

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(
    () => localStorage.getItem('fk_admin_auth') === 'true'
  );
  const [page, setPage] = useState('dashboard');

  function handleLogout() {
    localStorage.removeItem('fk_admin_auth');
    setIsLoggedIn(false);
    setPage('dashboard');
  }

  if (!isLoggedIn) {
    return <Login onLogin={() => setIsLoggedIn(true)} />;
  }

  const PageComponent = PAGES[page] || Dashboard;

  return (
    <ToastProvider>
      <div className="app-root">
        <Sidebar active={page} onNav={setPage} />
        <div className="app-main">
          <Topbar page={page} onNav={setPage} onLogout={handleLogout} />
          <main className="app-content">
            <PageComponent onNav={setPage} />
          </main>
        </div>
      </div>
    </ToastProvider>
  );
}