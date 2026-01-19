import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import {
  Plus,
  Pencil,
  Trash2,
  Loader2,
  Newspaper,
  Search,
  Calendar,
  Eye,
  EyeOff,
} from 'lucide-react';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { noticiasService } from '../services/firestore';
import type { Noticia, NoticiaFormData } from '../types';
import { NOTICIA_CATEGORIAS } from '../types';
import Modal from '../components/UI/Modal';
import Badge from '../components/UI/Badge';
import ConfirmDialog from '../components/UI/ConfirmDialog';
import toast from 'react-hot-toast';

export default function Noticias() {
  const [noticias, setNoticias] = useState<Noticia[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedNoticia, setSelectedNoticia] = useState<Noticia | null>(null);
  const [saving, setSaving] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors },
  } = useForm<NoticiaFormData>();

  useEffect(() => {
    loadNoticias();
  }, []);

  const loadNoticias = async () => {
    try {
      const data = await noticiasService.getAll();
      setNoticias(data);
    } catch (error) {
      console.error('Erro ao carregar notícias:', error);
      toast.error('Erro ao carregar notícias');
    } finally {
      setLoading(false);
    }
  };

  const openModal = (noticia?: Noticia) => {
    if (noticia) {
      setSelectedNoticia(noticia);
      reset({
        titulo: noticia.titulo,
        resumo: noticia.resumo,
        conteudo: noticia.conteudo,
        categoria: noticia.categoria,
        imagemURL: noticia.imagemURL,
        fonte: noticia.fonte,
        ativo: noticia.ativo,
      });
    } else {
      setSelectedNoticia(null);
      reset({
        titulo: '',
        resumo: '',
        conteudo: '',
        categoria: 'geral',
        imagemURL: '',
        fonte: '',
        ativo: true,
      });
    }
    setModalOpen(true);
  };

  const onSubmit = async (data: NoticiaFormData) => {
    setSaving(true);
    try {
      if (selectedNoticia) {
        await noticiasService.update(selectedNoticia.id, data);
        toast.success('Notícia atualizada com sucesso!');
      } else {
        await noticiasService.create(data);
        toast.success('Notícia publicada com sucesso!');
      }
      setModalOpen(false);
      loadNoticias();
    } catch (error) {
      console.error('Erro ao salvar notícia:', error);
      toast.error('Erro ao salvar notícia');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!selectedNoticia) return;
    setSaving(true);
    try {
      await noticiasService.delete(selectedNoticia.id);
      toast.success('Notícia excluída com sucesso!');
      setDeleteDialogOpen(false);
      setSelectedNoticia(null);
      loadNoticias();
    } catch (error) {
      console.error('Erro ao excluir notícia:', error);
      toast.error('Erro ao excluir notícia');
    } finally {
      setSaving(false);
    }
  };

  const toggleAtivo = async (noticia: Noticia) => {
    try {
      await noticiasService.update(noticia.id, { ativo: !noticia.ativo });
      toast.success(noticia.ativo ? 'Notícia desativada' : 'Notícia ativada');
      loadNoticias();
    } catch (error) {
      console.error('Erro ao atualizar status:', error);
      toast.error('Erro ao atualizar status');
    }
  };

  const getCategoryBadge = (categoria: Noticia['categoria']) => {
    const colors: Record<string, 'info' | 'success' | 'warning' | 'danger' | 'default'> = {
      geral: 'default',
      politica: 'info',
      esportes: 'success',
      cultura: 'warning',
      economia: 'danger',
      saude: 'success',
      educacao: 'info',
    };
    const label = NOTICIA_CATEGORIAS.find((c) => c.value === categoria)?.label;
    return <Badge variant={colors[categoria]}>{label}</Badge>;
  };

  const filteredNoticias = noticias.filter(
    (n) =>
      n.titulo.toLowerCase().includes(searchTerm.toLowerCase()) ||
      n.resumo.toLowerCase().includes(searchTerm.toLowerCase())
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
            <Newspaper className="w-8 h-8 text-indigo-500" />
            Notícias
          </h1>
          <p className="text-slate-500 mt-1">
            Gerencie as notícias da cidade
          </p>
        </div>
        <button onClick={() => openModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          Nova Notícia
        </button>
      </div>

      {/* Search */}
      <div className="card mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
          <input
            type="text"
            placeholder="Buscar notícias..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="input pl-10"
          />
        </div>
      </div>

      {/* Lista de Notícias */}
      {filteredNoticias.length === 0 ? (
        <div className="card text-center py-12">
          <Newspaper className="w-12 h-12 text-slate-300 mx-auto mb-4" />
          <p className="text-slate-500">Nenhuma notícia encontrada</p>
        </div>
      ) : (
        <div className="space-y-4">
          {filteredNoticias.map((noticia) => (
            <div
              key={noticia.id}
              className={`card hover:shadow-lg transition-shadow ${
                !noticia.ativo ? 'opacity-60' : ''
              }`}
            >
              <div className="flex gap-4">
                {/* Imagem */}
                <div className="hidden sm:block w-40 h-28 flex-shrink-0 rounded-lg overflow-hidden bg-slate-200">
                  {noticia.imagemURL ? (
                    <img
                      src={noticia.imagemURL}
                      alt={noticia.titulo}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="flex items-center justify-center h-full">
                      <Newspaper className="w-8 h-8 text-slate-400" />
                    </div>
                  )}
                </div>

                {/* Conteúdo */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-4">
                    <div className="flex items-center gap-2 mb-2">
                      {getCategoryBadge(noticia.categoria)}
                      {!noticia.ativo && (
                        <Badge variant="default">
                          <span className="flex items-center gap-1">
                            <EyeOff className="w-3 h-3" />
                            Inativa
                          </span>
                        </Badge>
                      )}
                    </div>
                    <div className="flex gap-1 flex-shrink-0">
                      <button
                        onClick={() => toggleAtivo(noticia)}
                        className={`p-2 rounded-lg ${
                          noticia.ativo
                            ? 'text-slate-400 hover:text-yellow-500 hover:bg-yellow-50'
                            : 'text-slate-400 hover:text-green-500 hover:bg-green-50'
                        }`}
                        title={noticia.ativo ? 'Desativar' : 'Ativar'}
                      >
                        {noticia.ativo ? (
                          <EyeOff className="w-4 h-4" />
                        ) : (
                          <Eye className="w-4 h-4" />
                        )}
                      </button>
                      <button
                        onClick={() => openModal(noticia)}
                        className="p-2 text-slate-400 hover:text-primary-500 hover:bg-slate-100 rounded-lg"
                      >
                        <Pencil className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => {
                          setSelectedNoticia(noticia);
                          setDeleteDialogOpen(true);
                        }}
                        className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-lg"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>

                  <h3 className="text-lg font-semibold text-slate-900 mb-1 line-clamp-1">
                    {noticia.titulo}
                  </h3>
                  <p className="text-slate-500 text-sm mb-3 line-clamp-2">
                    {noticia.resumo}
                  </p>

                  <div className="flex items-center gap-4 text-xs text-slate-400">
                    <div className="flex items-center gap-1">
                      <Calendar className="w-3 h-3" />
                      <span>
                        {format(noticia.publicadoEm, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                      </span>
                    </div>
                    {noticia.fonte && (
                      <span className="truncate">Fonte: {noticia.fonte}</span>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal de Criação/Edição */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={selectedNoticia ? 'Editar Notícia' : 'Nova Notícia'}
        size="lg"
      >
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="label">Título *</label>
            <input
              {...register('titulo', { required: 'Título é obrigatório' })}
              className="input"
              placeholder="Ex: Nova praça é inaugurada no centro"
            />
            {errors.titulo && (
              <p className="text-red-500 text-sm mt-1">{errors.titulo.message}</p>
            )}
          </div>

          <div>
            <label className="label">Resumo *</label>
            <textarea
              {...register('resumo', { required: 'Resumo é obrigatório' })}
              className="input min-h-[80px]"
              placeholder="Breve descrição da notícia..."
            />
            {errors.resumo && (
              <p className="text-red-500 text-sm mt-1">{errors.resumo.message}</p>
            )}
          </div>

          <div>
            <label className="label">Conteúdo Completo *</label>
            <textarea
              {...register('conteudo', { required: 'Conteúdo é obrigatório' })}
              className="input min-h-[150px]"
              placeholder="Texto completo da notícia..."
            />
            {errors.conteudo && (
              <p className="text-red-500 text-sm mt-1">{errors.conteudo.message}</p>
            )}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Categoria *</label>
              <select {...register('categoria')} className="input">
                {NOTICIA_CATEGORIAS.map((cat) => (
                  <option key={cat.value} value={cat.value}>
                    {cat.label}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="label">Fonte</label>
              <input
                {...register('fonte')}
                className="input"
                placeholder="Ex: Prefeitura Municipal"
              />
            </div>
          </div>

          <div>
            <label className="label">URL da Imagem</label>
            <input
              {...register('imagemURL')}
              type="url"
              className="input"
              placeholder="https://exemplo.com/imagem.jpg"
            />
          </div>

          <div className="flex items-center gap-4">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                {...register('ativo')}
                type="checkbox"
                className="w-4 h-4 text-primary-500 rounded"
              />
              <span className="text-sm text-slate-700">Notícia Ativa (visível no app)</span>
            </label>
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
                'Publicar'
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
        title="Excluir Notícia"
        message={`Tem certeza que deseja excluir a notícia "${selectedNoticia?.titulo}"? Esta ação não pode ser desfeita.`}
        confirmText="Excluir"
        loading={saving}
      />
    </div>
  );
}
