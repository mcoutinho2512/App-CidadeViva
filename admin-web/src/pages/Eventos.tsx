import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import {
  Plus,
  Pencil,
  Trash2,
  Loader2,
  Calendar,
  Search,
  MapPin,
  Clock,
} from 'lucide-react';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { eventosService } from '../services/firestore';
import type { Evento, EventoFormData } from '../types';
import { EVENTO_CATEGORIAS } from '../types';
import Modal from '../components/UI/Modal';
import Badge from '../components/UI/Badge';
import ConfirmDialog from '../components/UI/ConfirmDialog';
import toast from 'react-hot-toast';

export default function Eventos() {
  const [eventos, setEventos] = useState<Evento[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedEvento, setSelectedEvento] = useState<Evento | null>(null);
  const [saving, setSaving] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  const {
    register,
    handleSubmit,
    reset,
    watch,
    formState: { errors },
  } = useForm<EventoFormData>();

  const gratuito = watch('gratuito');

  useEffect(() => {
    loadEventos();
  }, []);

  const loadEventos = async () => {
    try {
      const data = await eventosService.getAll();
      setEventos(data);
    } catch (error) {
      console.error('Erro ao carregar eventos:', error);
      toast.error('Erro ao carregar eventos');
    } finally {
      setLoading(false);
    }
  };

  const openModal = (evento?: Evento) => {
    if (evento) {
      setSelectedEvento(evento);
      reset({
        titulo: evento.titulo,
        descricao: evento.descricao,
        categoria: evento.categoria,
        dataInicio: format(evento.dataInicio, "yyyy-MM-dd'T'HH:mm"),
        dataFim: evento.dataFim
          ? format(evento.dataFim, "yyyy-MM-dd'T'HH:mm")
          : undefined,
        local: evento.local,
        latitude: evento.coordenadas?.latitude,
        longitude: evento.coordenadas?.longitude,
        organizador: evento.organizador,
        gratuito: evento.gratuito,
        preco: evento.preco,
      });
    } else {
      setSelectedEvento(null);
      reset({
        titulo: '',
        descricao: '',
        categoria: 'cultural',
        dataInicio: '',
        local: '',
        organizador: '',
        gratuito: true,
      });
    }
    setModalOpen(true);
  };

  const onSubmit = async (data: EventoFormData) => {
    setSaving(true);
    try {
      if (selectedEvento) {
        await eventosService.update(selectedEvento.id, data);
        toast.success('Evento atualizado com sucesso!');
      } else {
        await eventosService.create(data);
        toast.success('Evento criado com sucesso!');
      }
      setModalOpen(false);
      loadEventos();
    } catch (error) {
      console.error('Erro ao salvar evento:', error);
      toast.error('Erro ao salvar evento');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!selectedEvento) return;
    setSaving(true);
    try {
      await eventosService.delete(selectedEvento.id);
      toast.success('Evento excluído com sucesso!');
      setDeleteDialogOpen(false);
      setSelectedEvento(null);
      loadEventos();
    } catch (error) {
      console.error('Erro ao excluir evento:', error);
      toast.error('Erro ao excluir evento');
    } finally {
      setSaving(false);
    }
  };

  const getCategoryBadge = (categoria: Evento['categoria']) => {
    const colors: Record<string, 'info' | 'success' | 'warning' | 'danger' | 'default'> = {
      cultural: 'info',
      esportivo: 'success',
      educacional: 'warning',
      comunitario: 'default',
      religioso: 'default',
      outros: 'default',
    };
    const label = EVENTO_CATEGORIAS.find((c) => c.value === categoria)?.label;
    return <Badge variant={colors[categoria]}>{label}</Badge>;
  };

  const isEventoPassado = (dataInicio: Date) => {
    return new Date(dataInicio) < new Date();
  };

  const filteredEventos = eventos.filter(
    (e) =>
      e.titulo.toLowerCase().includes(searchTerm.toLowerCase()) ||
      e.local.toLowerCase().includes(searchTerm.toLowerCase())
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
            <Calendar className="w-8 h-8 text-purple-500" />
            Eventos
          </h1>
          <p className="text-slate-500 mt-1">
            Gerencie os eventos da cidade
          </p>
        </div>
        <button onClick={() => openModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          Novo Evento
        </button>
      </div>

      {/* Search */}
      <div className="card mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
          <input
            type="text"
            placeholder="Buscar eventos..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="input pl-10"
          />
        </div>
      </div>

      {/* Grid de Eventos */}
      {filteredEventos.length === 0 ? (
        <div className="card text-center py-12">
          <Calendar className="w-12 h-12 text-slate-300 mx-auto mb-4" />
          <p className="text-slate-500">Nenhum evento encontrado</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredEventos.map((evento) => (
            <div
              key={evento.id}
              className={`card hover:shadow-lg transition-shadow ${
                isEventoPassado(evento.dataInicio) ? 'opacity-60' : ''
              }`}
            >
              {/* Header do Card */}
              <div className="flex items-start justify-between mb-4">
                {getCategoryBadge(evento.categoria)}
                <div className="flex gap-1">
                  <button
                    onClick={() => openModal(evento)}
                    className="p-2 text-slate-400 hover:text-primary-500 hover:bg-slate-100 rounded-lg"
                  >
                    <Pencil className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => {
                      setSelectedEvento(evento);
                      setDeleteDialogOpen(true);
                    }}
                    className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-lg"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>

              {/* Conteúdo */}
              <h3 className="text-lg font-semibold text-slate-900 mb-2">
                {evento.titulo}
              </h3>
              <p className="text-slate-500 text-sm mb-4 line-clamp-2">
                {evento.descricao}
              </p>

              {/* Info */}
              <div className="space-y-2 text-sm">
                <div className="flex items-center gap-2 text-slate-600">
                  <Clock className="w-4 h-4" />
                  <span>
                    {format(evento.dataInicio, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                  </span>
                </div>
                <div className="flex items-center gap-2 text-slate-600">
                  <MapPin className="w-4 h-4" />
                  <span className="truncate">{evento.local}</span>
                </div>
              </div>

              {/* Footer */}
              <div className="mt-4 pt-4 border-t border-slate-100 flex items-center justify-between">
                <span className="text-sm text-slate-500">{evento.organizador}</span>
                <span
                  className={`text-sm font-medium ${
                    evento.gratuito ? 'text-green-600' : 'text-primary-600'
                  }`}
                >
                  {evento.gratuito ? 'Gratuito' : `R$ ${evento.preco?.toFixed(2)}`}
                </span>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal de Criação/Edição */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={selectedEvento ? 'Editar Evento' : 'Novo Evento'}
        size="lg"
      >
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="label">Título *</label>
            <input
              {...register('titulo', { required: 'Título é obrigatório' })}
              className="input"
              placeholder="Ex: Festival de Música"
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
              placeholder="Descreva o evento..."
            />
            {errors.descricao && (
              <p className="text-red-500 text-sm mt-1">{errors.descricao.message}</p>
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Categoria *</label>
              <select {...register('categoria')} className="input">
                {EVENTO_CATEGORIAS.map((cat) => (
                  <option key={cat.value} value={cat.value}>
                    {cat.label}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="label">Organizador *</label>
              <input
                {...register('organizador', { required: 'Organizador é obrigatório' })}
                className="input"
                placeholder="Ex: Prefeitura"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Data/Hora Início *</label>
              <input
                {...register('dataInicio', { required: 'Data de início é obrigatória' })}
                type="datetime-local"
                className="input"
              />
              {errors.dataInicio && (
                <p className="text-red-500 text-sm mt-1">{errors.dataInicio.message}</p>
              )}
            </div>
            <div>
              <label className="label">Data/Hora Fim</label>
              <input
                {...register('dataFim')}
                type="datetime-local"
                className="input"
              />
            </div>
          </div>

          <div>
            <label className="label">Local *</label>
            <input
              {...register('local', { required: 'Local é obrigatório' })}
              className="input"
              placeholder="Ex: Praça Central"
            />
            {errors.local && (
              <p className="text-red-500 text-sm mt-1">{errors.local.message}</p>
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

          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                {...register('gratuito')}
                type="checkbox"
                className="w-4 h-4 text-primary-500 rounded"
              />
              <span className="text-sm text-slate-700">Evento Gratuito</span>
            </label>
          </div>

          {!gratuito && (
            <div>
              <label className="label">Preço (R$)</label>
              <input
                {...register('preco', { valueAsNumber: true })}
                type="number"
                step="0.01"
                className="input"
                placeholder="0.00"
              />
            </div>
          )}

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
        title="Excluir Evento"
        message={`Tem certeza que deseja excluir o evento "${selectedEvento?.titulo}"? Esta ação não pode ser desfeita.`}
        confirmText="Excluir"
        loading={saving}
      />
    </div>
  );
}
