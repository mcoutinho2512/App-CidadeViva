import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import {
  Plus,
  Pencil,
  Trash2,
  Loader2,
  Bell,
  Search,
  ToggleLeft,
  ToggleRight,
} from 'lucide-react';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { alertasService } from '../services/firestore';
import type { Alerta, AlertaFormData } from '../types';
import { ALERT_TYPES, ALERT_SEVERITIES } from '../types';
import Modal from '../components/UI/Modal';
import Badge from '../components/UI/Badge';
import ConfirmDialog from '../components/UI/ConfirmDialog';
import toast from 'react-hot-toast';

export default function Alertas() {
  const [alertas, setAlertas] = useState<Alerta[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedAlerta, setSelectedAlerta] = useState<Alerta | null>(null);
  const [saving, setSaving] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<AlertaFormData>();

  useEffect(() => {
    loadAlertas();
  }, []);

  const loadAlertas = async () => {
    try {
      const data = await alertasService.getAll();
      setAlertas(data);
    } catch (error) {
      console.error('Erro ao carregar alertas:', error);
      toast.error('Erro ao carregar alertas');
    } finally {
      setLoading(false);
    }
  };

  const openModal = (alerta?: Alerta) => {
    if (alerta) {
      setSelectedAlerta(alerta);
      reset({
        titulo: alerta.titulo,
        descricao: alerta.descricao,
        tipo: alerta.tipo,
        severidade: alerta.severidade,
        localizacao: alerta.localizacao,
        latitude: alerta.coordenadas?.latitude,
        longitude: alerta.coordenadas?.longitude,
        expiraEm: alerta.expiraEm
          ? format(alerta.expiraEm, "yyyy-MM-dd'T'HH:mm")
          : undefined,
      });
    } else {
      setSelectedAlerta(null);
      reset({
        titulo: '',
        descricao: '',
        tipo: 'traffic',
        severidade: 'medium',
        localizacao: '',
      });
    }
    setModalOpen(true);
  };

  const onSubmit = async (data: AlertaFormData) => {
    setSaving(true);
    try {
      if (selectedAlerta) {
        await alertasService.update(selectedAlerta.id, data);
        toast.success('Alerta atualizado com sucesso!');
      } else {
        await alertasService.create(data);
        toast.success('Alerta criado com sucesso!');
      }
      setModalOpen(false);
      loadAlertas();
    } catch (error) {
      console.error('Erro ao salvar alerta:', error);
      toast.error('Erro ao salvar alerta');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!selectedAlerta) return;
    setSaving(true);
    try {
      await alertasService.delete(selectedAlerta.id);
      toast.success('Alerta excluído com sucesso!');
      setDeleteDialogOpen(false);
      setSelectedAlerta(null);
      loadAlertas();
    } catch (error) {
      console.error('Erro ao excluir alerta:', error);
      toast.error('Erro ao excluir alerta');
    } finally {
      setSaving(false);
    }
  };

  const toggleAtivo = async (alerta: Alerta) => {
    try {
      await alertasService.toggleAtivo(alerta.id, !alerta.ativo);
      toast.success(
        alerta.ativo ? 'Alerta desativado' : 'Alerta ativado'
      );
      loadAlertas();
    } catch (error) {
      console.error('Erro ao atualizar status:', error);
      toast.error('Erro ao atualizar status');
    }
  };

  const getSeverityBadge = (severidade: Alerta['severidade']) => {
    const variants: Record<string, 'success' | 'warning' | 'danger' | 'info'> = {
      low: 'success',
      medium: 'warning',
      high: 'danger',
      critical: 'danger',
    };
    const labels = ALERT_SEVERITIES.find((s) => s.value === severidade);
    return (
      <Badge variant={variants[severidade]}>{labels?.label || severidade}</Badge>
    );
  };

  const filteredAlertas = alertas.filter(
    (a) =>
      a.titulo.toLowerCase().includes(searchTerm.toLowerCase()) ||
      a.localizacao.toLowerCase().includes(searchTerm.toLowerCase())
  );

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
            <Bell className="w-8 h-8 text-orange-500" />
            Alertas
          </h1>
          <p className="text-slate-500 mt-1">
            Gerencie os alertas da cidade
          </p>
        </div>
        <button onClick={() => openModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          Novo Alerta
        </button>
      </div>

      {/* Search */}
      <div className="card mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
          <input
            type="text"
            placeholder="Buscar alertas..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="input pl-10"
          />
        </div>
      </div>

      {/* Table */}
      <div className="card overflow-hidden p-0">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="table-header">Título</th>
                <th className="table-header">Tipo</th>
                <th className="table-header">Severidade</th>
                <th className="table-header">Local</th>
                <th className="table-header">Status</th>
                <th className="table-header">Criado em</th>
                <th className="table-header text-right">Ações</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-200">
              {filteredAlertas.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center text-slate-500">
                    Nenhum alerta encontrado
                  </td>
                </tr>
              ) : (
                filteredAlertas.map((alerta) => (
                  <tr key={alerta.id} className="hover:bg-slate-50">
                    <td className="table-cell font-medium">{alerta.titulo}</td>
                    <td className="table-cell">
                      {ALERT_TYPES.find((t) => t.value === alerta.tipo)?.label}
                    </td>
                    <td className="table-cell">{getSeverityBadge(alerta.severidade)}</td>
                    <td className="table-cell text-slate-500">{alerta.localizacao}</td>
                    <td className="table-cell">
                      <button
                        onClick={() => toggleAtivo(alerta)}
                        className="flex items-center gap-2"
                      >
                        {alerta.ativo ? (
                          <ToggleRight className="w-6 h-6 text-green-500" />
                        ) : (
                          <ToggleLeft className="w-6 h-6 text-slate-400" />
                        )}
                        <span className={alerta.ativo ? 'text-green-600' : 'text-slate-500'}>
                          {alerta.ativo ? 'Ativo' : 'Inativo'}
                        </span>
                      </button>
                    </td>
                    <td className="table-cell text-slate-500">
                      {format(alerta.criadoEm, "dd/MM/yyyy HH:mm", { locale: ptBR })}
                    </td>
                    <td className="table-cell text-right">
                      <div className="flex items-center justify-end gap-2">
                        <button
                          onClick={() => openModal(alerta)}
                          className="p-2 text-slate-400 hover:text-primary-500 hover:bg-slate-100 rounded-lg"
                        >
                          <Pencil className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => {
                            setSelectedAlerta(alerta);
                            setDeleteDialogOpen(true);
                          }}
                          className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-lg"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal de Criação/Edição */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={selectedAlerta ? 'Editar Alerta' : 'Novo Alerta'}
        size="lg"
      >
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="label">Título *</label>
            <input
              {...register('titulo', { required: 'Título é obrigatório' })}
              className="input"
              placeholder="Ex: Alagamento na Av. Principal"
            />
            {errors.titulo && (
              <p className="text-red-500 text-sm mt-1">{errors.titulo.message}</p>
            )}
          </div>

          <div>
            <label className="label">Descrição *</label>
            <textarea
              {...register('descricao', { required: 'Descrição é obrigatória' })}
              className="input min-h-[100px]"
              placeholder="Descreva o alerta em detalhes..."
            />
            {errors.descricao && (
              <p className="text-red-500 text-sm mt-1">{errors.descricao.message}</p>
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Tipo *</label>
              <select {...register('tipo')} className="input">
                {ALERT_TYPES.map((tipo) => (
                  <option key={tipo.value} value={tipo.value}>
                    {tipo.label}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="label">Severidade *</label>
              <select {...register('severidade')} className="input">
                {ALERT_SEVERITIES.map((sev) => (
                  <option key={sev.value} value={sev.value}>
                    {sev.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="label">Localização *</label>
            <input
              {...register('localizacao', { required: 'Localização é obrigatória' })}
              className="input"
              placeholder="Ex: Av. Principal, Centro"
            />
            {errors.localizacao && (
              <p className="text-red-500 text-sm mt-1">{errors.localizacao.message}</p>
            )}
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
            <label className="label">Expira em</label>
            <input
              {...register('expiraEm')}
              type="datetime-local"
              className="input"
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
        title="Excluir Alerta"
        message={`Tem certeza que deseja excluir o alerta "${selectedAlerta?.titulo}"? Esta ação não pode ser desfeita.`}
        confirmText="Excluir"
        loading={saving}
      />
    </div>
  );
}
