// Tipos para o sistema de administração CidadeViva

// ==================== ALERTAS ====================
export type AlertType = 'traffic' | 'weather' | 'security' | 'infrastructure' | 'event' | 'emergency';
export type AlertSeverity = 'low' | 'medium' | 'high' | 'critical';

export interface Alerta {
  id: string;
  titulo: string;
  descricao: string;
  tipo: AlertType;
  severidade: AlertSeverity;
  localizacao: string;
  coordenadas?: {
    latitude: number;
    longitude: number;
  };
  ativo: boolean;
  criadoEm: Date;
  expiraEm?: Date;
}

export interface AlertaFormData {
  titulo: string;
  descricao: string;
  tipo: AlertType;
  severidade: AlertSeverity;
  localizacao: string;
  latitude?: number;
  longitude?: number;
  expiraEm?: string;
}

// ==================== EVENTOS ====================
export type EventoCategoria = 'cultural' | 'esportivo' | 'educacional' | 'comunitario' | 'religioso' | 'outros';

export interface Evento {
  id: string;
  titulo: string;
  descricao: string;
  categoria: EventoCategoria;
  dataInicio: Date;
  dataFim?: Date;
  local: string;
  coordenadas?: {
    latitude: number;
    longitude: number;
  };
  imagemURL?: string;
  organizador: string;
  gratuito: boolean;
  preco?: number;
  criadoEm: Date;
}

export interface EventoFormData {
  titulo: string;
  descricao: string;
  categoria: EventoCategoria;
  dataInicio: string;
  dataFim?: string;
  local: string;
  latitude?: number;
  longitude?: number;
  organizador: string;
  gratuito: boolean;
  preco?: number;
}

// ==================== CÂMERAS ====================
export type CameraStatus = 'online' | 'offline' | 'maintenance';

export interface Camera {
  id: string;
  nome: string;
  regiao: string;
  status: CameraStatus;
  coordenadas: {
    latitude: number;
    longitude: number;
  };
  streamURL?: string;
  thumbnailURL?: string;
  atualizadoEm: Date;
}

export interface CameraFormData {
  nome: string;
  regiao: string;
  status: CameraStatus;
  latitude: number;
  longitude: number;
  streamURL?: string;
  thumbnailURL?: string;
}

// ==================== NOTÍCIAS ====================
export type NoticiaCategoria = 'cidade' | 'saude' | 'educacao' | 'transporte' | 'cultura' | 'esportes' | 'economia' | 'outros';

export interface Noticia {
  id: string;
  titulo: string;
  resumo: string;
  conteudo: string;
  categoria: NoticiaCategoria;
  imagemURL?: string;
  fonte: string;
  publicadoEm: Date;
  ativo: boolean;
  criadoEm: Date;
}

export interface NoticiaFormData {
  titulo: string;
  resumo: string;
  conteudo: string;
  categoria: NoticiaCategoria;
  fonte: string;
  publicadoEm?: string;
  ativo: boolean;
}

// ==================== BANNERS ====================
export interface Banner {
  id: string;
  titulo: string;
  subtitulo: string;
  imagemURL: string;
  linkURL?: string;
  ordem: number;
  ativo: boolean;
  criadoEm: Date;
}

export interface BannerFormData {
  titulo: string;
  subtitulo: string;
  imagemURL: string;
  linkURL?: string;
  ordem: number;
  ativo: boolean;
}

// ==================== USUÁRIOS ADMIN ====================
export type AdminRole = 'admin' | 'editor' | 'viewer';

export interface AdminUser {
  id: string;
  email: string;
  nome: string;
  role: AdminRole;
  criadoEm: Date;
  ultimoAcesso?: Date;
}

// ==================== ESTATÍSTICAS ====================
export interface DashboardStats {
  totalAlertas: number;
  alertasAtivos: number;
  totalEventos: number;
  eventosProximos: number;
  totalCameras: number;
  camerasOnline: number;
  totalNoticias: number;
  noticiasAtivas: number;
}

// ==================== HELPERS ====================
export const ALERT_TYPES: { value: AlertType; label: string }[] = [
  { value: 'traffic', label: 'Trânsito' },
  { value: 'weather', label: 'Clima' },
  { value: 'security', label: 'Segurança' },
  { value: 'infrastructure', label: 'Infraestrutura' },
  { value: 'event', label: 'Evento' },
  { value: 'emergency', label: 'Emergência' },
];

export const ALERT_SEVERITIES: { value: AlertSeverity; label: string; color: string }[] = [
  { value: 'low', label: 'Baixa', color: 'green' },
  { value: 'medium', label: 'Média', color: 'yellow' },
  { value: 'high', label: 'Alta', color: 'orange' },
  { value: 'critical', label: 'Crítica', color: 'red' },
];

export const EVENTO_CATEGORIAS: { value: EventoCategoria; label: string }[] = [
  { value: 'cultural', label: 'Cultural' },
  { value: 'esportivo', label: 'Esportivo' },
  { value: 'educacional', label: 'Educacional' },
  { value: 'comunitario', label: 'Comunitário' },
  { value: 'religioso', label: 'Religioso' },
  { value: 'outros', label: 'Outros' },
];

export const CAMERA_STATUS: { value: CameraStatus; label: string; color: string }[] = [
  { value: 'online', label: 'Online', color: 'green' },
  { value: 'offline', label: 'Offline', color: 'red' },
  { value: 'maintenance', label: 'Manutenção', color: 'yellow' },
];

export const NOTICIA_CATEGORIAS: { value: NoticiaCategoria; label: string }[] = [
  { value: 'cidade', label: 'Cidade' },
  { value: 'saude', label: 'Saúde' },
  { value: 'educacao', label: 'Educação' },
  { value: 'transporte', label: 'Transporte' },
  { value: 'cultura', label: 'Cultura' },
  { value: 'esportes', label: 'Esportes' },
  { value: 'economia', label: 'Economia' },
  { value: 'outros', label: 'Outros' },
];
