import { useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import {
  Plus,
  Pencil,
  Trash2,
  Loader2,
  Image,
  Eye,
  EyeOff,
  GripVertical,
  ExternalLink,
} from 'lucide-react';
import { bannersService } from '../services/firestore';
import type { Banner, BannerFormData } from '../types';
import Modal from '../components/UI/Modal';
import Badge from '../components/UI/Badge';
import ConfirmDialog from '../components/UI/ConfirmDialog';
import toast from 'react-hot-toast';

export default function Banners() {
  const [banners, setBanners] = useState<Banner[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [selectedBanner, setSelectedBanner] = useState<Banner | null>(null);
  const [saving, setSaving] = useState(false);

  const {
    register,
    handleSubmit,
    reset,
    watch,
    formState: { errors },
  } = useForm<BannerFormData>();

  const imagemURL = watch('imagemURL');

  useEffect(() => {
    loadBanners();
  }, []);

  const loadBanners = async () => {
    try {
      const data = await bannersService.getAll();
      setBanners(data);
    } catch (error) {
      console.error('Erro ao carregar banners:', error);
      toast.error('Erro ao carregar banners');
    } finally {
      setLoading(false);
    }
  };

  const openModal = (banner?: Banner) => {
    if (banner) {
      setSelectedBanner(banner);
      reset({
        titulo: banner.titulo,
        subtitulo: banner.subtitulo,
        imagemURL: banner.imagemURL,
        linkURL: banner.linkURL,
        ordem: banner.ordem,
        ativo: banner.ativo,
      });
    } else {
      setSelectedBanner(null);
      reset({
        titulo: '',
        subtitulo: '',
        imagemURL: '',
        linkURL: '',
        ordem: banners.length + 1,
        ativo: true,
      });
    }
    setModalOpen(true);
  };

  const onSubmit = async (data: BannerFormData) => {
    setSaving(true);
    try {
      if (selectedBanner) {
        await bannersService.update(selectedBanner.id, data);
        toast.success('Banner atualizado com sucesso!');
      } else {
        await bannersService.create(data);
        toast.success('Banner criado com sucesso!');
      }
      setModalOpen(false);
      loadBanners();
    } catch (error) {
      console.error('Erro ao salvar banner:', error);
      toast.error('Erro ao salvar banner');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!selectedBanner) return;
    setSaving(true);
    try {
      await bannersService.delete(selectedBanner.id);
      toast.success('Banner excluído com sucesso!');
      setDeleteDialogOpen(false);
      setSelectedBanner(null);
      loadBanners();
    } catch (error) {
      console.error('Erro ao excluir banner:', error);
      toast.error('Erro ao excluir banner');
    } finally {
      setSaving(false);
    }
  };

  const toggleAtivo = async (banner: Banner) => {
    try {
      await bannersService.toggleAtivo(banner.id, !banner.ativo);
      toast.success(banner.ativo ? 'Banner desativado' : 'Banner ativado');
      loadBanners();
    } catch (error) {
      console.error('Erro ao atualizar status:', error);
      toast.error('Erro ao atualizar status');
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
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 flex items-center gap-3">
            <Image className="w-8 h-8 text-pink-500" />
            Banners
          </h1>
          <p className="text-slate-500 mt-1">
            Gerencie os banners do carrossel do app
          </p>
        </div>
        <button onClick={() => openModal()} className="btn-primary flex items-center gap-2">
          <Plus className="w-5 h-5" />
          Novo Banner
        </button>
      </div>

      {/* Info */}
      <div className="card bg-blue-50 border border-blue-200 mb-6">
        <p className="text-blue-700 text-sm">
          <strong>Dica:</strong> Os banners aparecem no carrossel da tela inicial do app.
          Use imagens com proporção 16:9 (ex: 1920x1080) para melhor visualização.
          A ordem define a sequência de exibição.
        </p>
      </div>

      {/* Lista de Banners */}
      {banners.length === 0 ? (
        <div className="card text-center py-12">
          <Image className="w-12 h-12 text-slate-300 mx-auto mb-4" />
          <p className="text-slate-500">Nenhum banner cadastrado</p>
          <button
            onClick={() => openModal()}
            className="mt-4 text-primary-500 hover:underline"
          >
            Criar primeiro banner
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {banners.map((banner) => (
            <div
              key={banner.id}
              className={`card hover:shadow-lg transition-shadow ${
                !banner.ativo ? 'opacity-60' : ''
              }`}
            >
              <div className="flex gap-4">
                {/* Ordem */}
                <div className="flex items-center text-slate-400">
                  <GripVertical className="w-5 h-5" />
                  <span className="ml-1 font-mono text-sm">{banner.ordem}</span>
                </div>

                {/* Imagem */}
                <div className="w-48 h-28 flex-shrink-0 rounded-lg overflow-hidden bg-slate-200">
                  {banner.imagemURL ? (
                    <img
                      src={banner.imagemURL}
                      alt={banner.titulo}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="flex items-center justify-center h-full">
                      <Image className="w-8 h-8 text-slate-400" />
                    </div>
                  )}
                </div>

                {/* Conteúdo */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-4">
                    <div className="flex items-center gap-2 mb-2">
                      {banner.ativo ? (
                        <Badge variant="success">Ativo</Badge>
                      ) : (
                        <Badge variant="default">Inativo</Badge>
                      )}
                    </div>
                    <div className="flex gap-1 flex-shrink-0">
                      <button
                        onClick={() => toggleAtivo(banner)}
                        className={`p-2 rounded-lg ${
                          banner.ativo
                            ? 'text-slate-400 hover:text-yellow-500 hover:bg-yellow-50'
                            : 'text-slate-400 hover:text-green-500 hover:bg-green-50'
                        }`}
                        title={banner.ativo ? 'Desativar' : 'Ativar'}
                      >
                        {banner.ativo ? (
                          <EyeOff className="w-4 h-4" />
                        ) : (
                          <Eye className="w-4 h-4" />
                        )}
                      </button>
                      <button
                        onClick={() => openModal(banner)}
                        className="p-2 text-slate-400 hover:text-primary-500 hover:bg-slate-100 rounded-lg"
                      >
                        <Pencil className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => {
                          setSelectedBanner(banner);
                          setDeleteDialogOpen(true);
                        }}
                        className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-lg"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>

                  <h3 className="text-lg font-semibold text-slate-900 mb-1">
                    {banner.titulo}
                  </h3>
                  <p className="text-slate-500 text-sm mb-2">
                    {banner.subtitulo}
                  </p>

                  {banner.linkURL && (
                    <a
                      href={banner.linkURL}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-1 text-xs text-primary-500 hover:underline"
                    >
                      <ExternalLink className="w-3 h-3" />
                      {banner.linkURL}
                    </a>
                  )}
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
        title={selectedBanner ? 'Editar Banner' : 'Novo Banner'}
        size="lg"
      >
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div>
            <label className="label">Título *</label>
            <input
              {...register('titulo', { required: 'Título é obrigatório' })}
              className="input"
              placeholder="Ex: Festa Junina 2024"
            />
            {errors.titulo && (
              <p className="text-red-500 text-sm mt-1">{errors.titulo.message}</p>
            )}
          </div>

          <div>
            <label className="label">Subtítulo *</label>
            <input
              {...register('subtitulo', { required: 'Subtítulo é obrigatório' })}
              className="input"
              placeholder="Ex: Venha celebrar conosco!"
            />
            {errors.subtitulo && (
              <p className="text-red-500 text-sm mt-1">{errors.subtitulo.message}</p>
            )}
          </div>

          <div>
            <label className="label">URL da Imagem *</label>
            <input
              {...register('imagemURL', { required: 'URL da imagem é obrigatória' })}
              type="url"
              className="input"
              placeholder="https://exemplo.com/banner.jpg"
            />
            {errors.imagemURL && (
              <p className="text-red-500 text-sm mt-1">{errors.imagemURL.message}</p>
            )}
            {imagemURL && (
              <div className="mt-2 rounded-lg overflow-hidden bg-slate-100">
                <img
                  src={imagemURL}
                  alt="Preview"
                  className="w-full h-32 object-cover"
                  onError={(e) => {
                    (e.target as HTMLImageElement).style.display = 'none';
                  }}
                />
              </div>
            )}
          </div>

          <div>
            <label className="label">URL de Destino (opcional)</label>
            <input
              {...register('linkURL')}
              type="url"
              className="input"
              placeholder="https://exemplo.com/evento"
            />
            <p className="text-slate-400 text-xs mt-1">
              Link que abre ao clicar no banner
            </p>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="label">Ordem *</label>
              <input
                {...register('ordem', {
                  required: 'Ordem é obrigatória',
                  valueAsNumber: true,
                  min: { value: 1, message: 'Mínimo 1' }
                })}
                type="number"
                min="1"
                className="input"
                placeholder="1"
              />
              {errors.ordem && (
                <p className="text-red-500 text-sm mt-1">{errors.ordem.message}</p>
              )}
            </div>
            <div className="flex items-end">
              <label className="flex items-center gap-2 cursor-pointer pb-2">
                <input
                  {...register('ativo')}
                  type="checkbox"
                  className="w-4 h-4 text-primary-500 rounded"
                />
                <span className="text-sm text-slate-700">Banner Ativo</span>
              </label>
            </div>
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
        title="Excluir Banner"
        message={`Tem certeza que deseja excluir o banner "${selectedBanner?.titulo}"? Esta ação não pode ser desfeita.`}
        confirmText="Excluir"
        loading={saving}
      />
    </div>
  );
}
