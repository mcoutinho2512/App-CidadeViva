import { useEffect, useState } from 'react';
import {
  Bell,
  Calendar,
  Camera,
  Newspaper,
  TrendingUp,
  AlertTriangle,
  CheckCircle,
  Loader2,
} from 'lucide-react';
import { statsService } from '../services/firestore';
import type { DashboardStats } from '../types';
import toast from 'react-hot-toast';

interface StatCardProps {
  title: string;
  value: number;
  subtitle: string;
  icon: React.ReactNode;
  color: 'blue' | 'orange' | 'green' | 'purple';
}

function StatCard({ title, value, subtitle, icon, color }: StatCardProps) {
  const colorClasses = {
    blue: 'bg-blue-500',
    orange: 'bg-orange-500',
    green: 'bg-green-500',
    purple: 'bg-purple-500',
  };

  return (
    <div className="card">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm font-medium text-slate-500">{title}</p>
          <p className="text-3xl font-bold text-slate-900 mt-1">{value}</p>
          <p className="text-sm text-slate-500 mt-1">{subtitle}</p>
        </div>
        <div
          className={`p-3 rounded-xl ${colorClasses[color]} text-white`}
        >
          {icon}
        </div>
      </div>
    </div>
  );
}

export default function Dashboard() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const data = await statsService.getDashboardStats();
      setStats(data);
    } catch (error) {
      console.error('Erro ao carregar estatísticas:', error);
      toast.error('Erro ao carregar estatísticas');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="w-8 h-8 animate-spin text-primary-500" />
      </div>
    );
  }

  return (
    <div>
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900">Dashboard</h1>
        <p className="text-slate-500 mt-1">
          Visão geral do sistema CidadeViva
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatCard
          title="Alertas"
          value={stats?.alertasAtivos || 0}
          subtitle={`${stats?.totalAlertas || 0} total`}
          icon={<Bell className="w-6 h-6" />}
          color="orange"
        />
        <StatCard
          title="Eventos"
          value={stats?.eventosProximos || 0}
          subtitle={`${stats?.totalEventos || 0} total`}
          icon={<Calendar className="w-6 h-6" />}
          color="purple"
        />
        <StatCard
          title="Câmeras"
          value={stats?.camerasOnline || 0}
          subtitle={`${stats?.totalCameras || 0} total`}
          icon={<Camera className="w-6 h-6" />}
          color="green"
        />
        <StatCard
          title="Notícias"
          value={stats?.noticiasAtivas || 0}
          subtitle={`${stats?.totalNoticias || 0} total`}
          icon={<Newspaper className="w-6 h-6" />}
          color="blue"
        />
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Status Geral */}
        <div className="card">
          <h2 className="text-lg font-semibold text-slate-900 mb-4">
            Status Geral
          </h2>
          <div className="space-y-4">
            <div className="flex items-center justify-between p-3 bg-green-50 rounded-lg">
              <div className="flex items-center gap-3">
                <CheckCircle className="w-5 h-5 text-green-600" />
                <span className="text-slate-700">Câmeras Online</span>
              </div>
              <span className="font-semibold text-green-600">
                {stats?.camerasOnline}/{stats?.totalCameras}
              </span>
            </div>
            <div className="flex items-center justify-between p-3 bg-orange-50 rounded-lg">
              <div className="flex items-center gap-3">
                <AlertTriangle className="w-5 h-5 text-orange-600" />
                <span className="text-slate-700">Alertas Ativos</span>
              </div>
              <span className="font-semibold text-orange-600">
                {stats?.alertasAtivos}
              </span>
            </div>
            <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
              <div className="flex items-center gap-3">
                <TrendingUp className="w-5 h-5 text-blue-600" />
                <span className="text-slate-700">Eventos Próximos</span>
              </div>
              <span className="font-semibold text-blue-600">
                {stats?.eventosProximos}
              </span>
            </div>
          </div>
        </div>

        {/* Ações Rápidas */}
        <div className="card">
          <h2 className="text-lg font-semibold text-slate-900 mb-4">
            Ações Rápidas
          </h2>
          <div className="grid grid-cols-2 gap-4">
            <a
              href="/alertas"
              className="flex flex-col items-center justify-center p-4 bg-orange-50 hover:bg-orange-100 rounded-xl transition-colors"
            >
              <Bell className="w-8 h-8 text-orange-600 mb-2" />
              <span className="text-sm font-medium text-slate-700">
                Novo Alerta
              </span>
            </a>
            <a
              href="/eventos"
              className="flex flex-col items-center justify-center p-4 bg-purple-50 hover:bg-purple-100 rounded-xl transition-colors"
            >
              <Calendar className="w-8 h-8 text-purple-600 mb-2" />
              <span className="text-sm font-medium text-slate-700">
                Novo Evento
              </span>
            </a>
            <a
              href="/cameras"
              className="flex flex-col items-center justify-center p-4 bg-green-50 hover:bg-green-100 rounded-xl transition-colors"
            >
              <Camera className="w-8 h-8 text-green-600 mb-2" />
              <span className="text-sm font-medium text-slate-700">
                Nova Câmera
              </span>
            </a>
            <a
              href="/noticias"
              className="flex flex-col items-center justify-center p-4 bg-blue-50 hover:bg-blue-100 rounded-xl transition-colors"
            >
              <Newspaper className="w-8 h-8 text-blue-600 mb-2" />
              <span className="text-sm font-medium text-slate-700">
                Nova Notícia
              </span>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
