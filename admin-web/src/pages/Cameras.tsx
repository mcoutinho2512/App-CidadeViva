import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import {
  Plus,
  Pencil,
  Trash2,
  Loader2,
  Video,
  Search,
  MapPin,
  Wifi,
  WifiOff,
  Wrench,
} from 'lucide-react';
import { camerasService } from '../services/firestore';
import type { Camera, CameraFormData } from '../types';
import { CAMERA_STATUS } from '../types';
import Modal from '../components/UI/Modal';
import Badge from '../components/UI/Badge';
import ConfirmDialog from '../components/UI/ConfirmDialog';
import toast from 'react-hot-toast';

export default function Cameras() {
  const [cameras, setCameras] = useState<Camera[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedCamera, setSelectedCamera] = useState<Camera | null>(null);
  const [saving, setSaving] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<CameraFormData>();

  useEffect(() => {
    loadCameras();
  }, []);

  const loadCameras = async () => {
    try {
      const data = await camerasService.getAll();
      setCameras(data);
    } catch (error) {
      console.error('Erro ao carregar câmeras:', error);
      toast.error('Erro ao carregar câmeras');
    } finally {
      setLoading(false);
    }
  };

  const openModal = (camera?: Camera) => {
    if (camera) {
      setSelectedCamera(camera);
      reset({
        nome: camera.nome,
        regiao: camera.regiao,
        status: camera.status,
        latitude: camera.coordenadas?.latitude,
        longitude: camera.coordenadas?.longitude,
        streamURL: camera.streamURL,
        thumbnailURL: camera.thumbnailURL,
      });
    } else {
      setSelectedCamera(null);
      reset({
        nome: '',
        regiao: '',
        status: 'online',
        streamURL: '',
        thumbnailURL: '',
      });
    }
    setModalOpen(true);
  };

  const onSubmit = async (data: CameraFormData) => {
    setSaving(true);
    try {
      if (selectedCamera) {
        await camerasService.update(selectedCamera.id, data);
        toast.success('Câmera atualizada com sucesso!');
      } else {
        await camerasService.create(data);
        toast.success('Câmera cadastrada com sucesso!');
      }
      setModalOpen(false);
      loadCameras();
    } catch (error) {
      console.error('Erro ao salvar câmera:', error);
      toast.error('Erro ao salvar câmera');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!selectedCamera) return;
    setSaving(true);
    try {
      await camerasService.delete(selectedCamera.id);
      toast.success('Câmera excluída com sucesso!');
      setDeleteDialogOpen(false);
      setSelectedCamera(null);
      loadCameras();
    } catch (error) {
      console.error('Erro ao excluir câmera:', error);
      toast.error('Erro ao excluir câmera');
    } finally {
      setSaving(false);
    }
  };

  const getStatusBadge = (status: Camera['status']) => {
    const config: Record<string, { variant: 'success' | 'danger' | 'warning'; icon: React.ReactNode }> = {
      online: { variant: 'success', icon: <Wifi className="w-3 h-3" /> },
      offline: { variant: 'danger', icon: <WifiOff className="w-3 h-3" /> },
      maintenance: { variant: 'warning', icon: <Wrench className="w-3 h-3" /> },
    };
    const label = CAMERA_STATUS.find((s) => s.value === status)?.label;
    return (
      <Badge variant={config[status].variant}>
        <span className="flex items-center gap-1">
          {config[status].icon}
          {label}
        </span>
      </Badge>
    );
  };

  const filteredCameras = cameras.filter(
    (c) =>
      c.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
      c.regiao.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const onlineCount = cameras.filter((c) => c.status === 'online').length;
  const offlineCount = cameras.filter((c) => c.status === 'offline').length;
  const maintenanceCount = cameras.filter((c) => c.status === 'maintenance').length;

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
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 flex items-center gap-3">
            <Video className="w-8 h-8 text-cyan-500" />
            Câmeras
          </h1>
          <p className="text-slate-500 mt-1">
            Gerencie as câmeras de monitoramento
          </p>
        </div>
        <button onClick={() => openModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          Nova Câmera
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <div className="card bg-green-50 border border-green-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-green-500 rounded-lg">
              <Wifi className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="text-sm text-green-600">Online</p>
              <p className="text-2xl font-bold text-green-700">{onlineCount}</p>
            </div>
          </div>
        </div>
        <div className="card bg-red-50 border border-red-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-red-500 rounded-lg">
              <WifiOff className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="text-sm text-red-600">Offline</p>
              <p className="text-2xl font-bold text-red-700">{offlineCount}</p>
            </div>
          </div>
        </div>
        <div className="card bg-yellow-50 border border-yellow-200">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-yellow-500 rounded-lg">
              <Wrench className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="text-sm text-yellow-600">Manutenção</p>
              <p className="text-2xl font-bold text-yellow-700">{maintenanceCount}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Search */}
      <div className="card mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
          <input
            type="text"
            placeholder="Buscar câmeras..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="input pl-10"
          />
        </div>
      </div>

      {/* Grid de Câmeras */}
      {filteredCameras.length === 0 ? (
        <div className="card text-center py-12">
          <Video className="w-12 h-12 text-slate-300 mx-auto mb-4" />
          <p className="text-slate-500">Nenhuma câmera encontrada</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredCameras.map((camera) => (
            <div key={camera.id} className="card hover:shadow-lg transition-shadow">
              {/* Thumbnail */}
              <div className="relative aspect-video bg-slate-200 rounded-lg mb-4 overflow-hidden">
                {camera.thumbnailURL ? (
                  <img
                    src={camera.thumbnailURL}
                    alt={camera.nome}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="flex items-center justify-center h-full">
                    <Video className="w-12 h-12 text-slate-400" />
                  </div>
                )}
                <div className="absolute top-2 left-2">
                  {getStatusBadge(camera.status)}
                </div>
                <div className="absolute top-2 right-2 flex gap-1">
                  <button
                    onClick={() => openModal(camera)}
                    className="p-2 bg-white/90 text-slate-600 hover:text-primary-500 rounded-lg shadow"
                  >
                    <Pencil className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => {
                      setSelectedCamera(camera);
                      setDeleteDialogOpen(true);
                    }}
                    className="p-2 bg-white/90 text-slate-600 hover:text-red-500 rounded-lg shadow"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Info */}
              <h3 className="text-lg font-semibold text-slate-900 mb-1">
                {camera.nome}
              </h3>
              <div className="flex items-center gap-2 text-slate-500 text-sm">
                <MapPin className="w-4 h-4" />
                <span>{camera.regiao}</span>
              </div>

              {/* Stream URL */}
              {camera.streamURL && (
                <a
                  href={camera.streamURL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="mt-3 block text-sm text-primary-500 hover:underline truncate"
                >
                  Abrir stream ao vivo
                </a>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Modal de Criação/Edição */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={selectedCamera ? 'Editar Câmera' : 'Nova Câmera'}
      >
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="label">Nome *</label>
            <input
              {...register('nome', { required: 'Nome é obrigatório' })}
              className="input"
              placeholder="Ex: Câmera Centro - Praça Principal"
            />
            {errors.nome && (
              <p className="text-red-500 text-sm mt-1">{errors.nome.message}</p>
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Região *</label>
              <input
                {...register('regiao', { required: 'Região é obrigatória' })}
                className="input"
                placeholder="Ex: Centro"
              />
              {errors.regiao && (
                <p className="text-red-500 text-sm mt-1">{errors.regiao.message}</p>
              )}
            </div>
            <div>
              <label className="label">Status *</label>
              <select {...register('status')} className="input">
                {CAMERA_STATUS.map((status) => (
                  <option key={status.value} value={status.value}>
                    {status.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Latitude</label>
              <input
                {...register('latitude', { valueAsNumber: true })}
                type="number"
                step="any"
                className="input"
                placeholder="-22.9035"
              />
            </div>
            <div>
              <label className="label">Longitude</label>
              <input
                {...register('longitude', { valueAsNumber: true })}
                type="number"
                step="any"
                className="input"
                placeholder="-43.1180"
              />
            </div>
          </div>

          <div>
            <label className="label">URL do Stream</label>
            <input
              {...register('streamURL')}
              type="url"
              className="input"
              placeholder="https://stream.exemplo.com/camera1"
            />
          </div>

          <div>
            <label className="label">URL da Thumbnail</label>
            <input
              {...register('thumbnailURL')}
              type="url"
              className="input"
              placeholder="https://exemplo.com/thumbnail.jpg"
            />
          </div>

          <div className="flex justify-end gap-3 pt-4">
            <button
              type="button"
              onClick={() => setModalOpen(false)}
              className="btn-secondary"
            >
              Cancelar
            </button>
            <button type="submit" disabled={saving} className="btn-primary">
              {saving ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin mr-2" />
                  Salvando...
                </>
              ) : (
                'Salvar'
              )}
            </button>
          </div>
        </form>
      </Modal>

      {/* Dialog de Confirmação de Exclusão */}
      <ConfirmDialog
        isOpen={deleteDialogOpen}
        onClose={() => setDeleteDialogOpen(false)}
        onConfirm={handleDelete}
        title="Excluir Câmera"
        message={`Tem certeza que deseja excluir a câmera "${selectedCamera?.nome}"? Esta ação não pode ser desfeita.`}
        confirmText="Excluir"
        loading={saving}
      />
    </div>
  );
}
