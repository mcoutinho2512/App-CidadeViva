import {
  collection,
  doc,
  getDocs,
  getDoc,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  Timestamp,
  DocumentData,
} from 'firebase/firestore';
import { db } from './firebase';
import type {
  Alerta,
  AlertaFormData,
  Evento,
  EventoFormData,
  Camera,
  CameraFormData,
  Noticia,
  NoticiaFormData,
  Banner,
  BannerFormData,
  DashboardStats,
} from '../types';

// ==================== ALERTAS ====================
const alertasRef = collection(db, 'alertas');

export const alertasService = {
  async getAll(): Promise<Alerta[]> {
    const q = query(alertasRef, orderBy('criadoEm', 'desc'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...convertTimestamps(doc.data()),
    })) as Alerta[];
  },

  async getById(id: string): Promise<Alerta | null> {
    const docRef = doc(alertasRef, id);
    const snapshot = await getDoc(docRef);
    if (!snapshot.exists()) return null;
    return { id: snapshot.id, ...convertTimestamps(snapshot.data()) } as Alerta;
  },

  async create(data: AlertaFormData): Promise<string> {
    const docData = {
      ...data,
      coordenadas: data.latitude && data.longitude
        ? { latitude: data.latitude, longitude: data.longitude }
        : null,
      ativo: true,
      criadoEm: Timestamp.now(),
      expiraEm: data.expiraEm ? Timestamp.fromDate(new Date(data.expiraEm)) : null,
    };
    delete (docData as any).latitude;
    delete (docData as any).longitude;
    const docRef = await addDoc(alertasRef, docData);
    return docRef.id;
  },

  async update(id: string, data: Partial<AlertaFormData>): Promise<void> {
    const docRef = doc(alertasRef, id);
    const updateData: any = { ...data };
    if (data.latitude !== undefined && data.longitude !== undefined) {
      updateData.coordenadas = { latitude: data.latitude, longitude: data.longitude };
      delete updateData.latitude;
      delete updateData.longitude;
    }
    if (data.expiraEm) {
      updateData.expiraEm = Timestamp.fromDate(new Date(data.expiraEm));
    }
    await updateDoc(docRef, updateData);
  },

  async delete(id: string): Promise<void> {
    const docRef = doc(alertasRef, id);
    await deleteDoc(docRef);
  },

  async toggleAtivo(id: string, ativo: boolean): Promise<void> {
    const docRef = doc(alertasRef, id);
    await updateDoc(docRef, { ativo });
  },
};

// ==================== EVENTOS ====================
const eventosRef = collection(db, 'eventos');

export const eventosService = {
  async getAll(): Promise<Evento[]> {
    const q = query(eventosRef, orderBy('dataInicio', 'desc'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...convertTimestamps(doc.data()),
    })) as Evento[];
  },

  async getById(id: string): Promise<Evento | null> {
    const docRef = doc(eventosRef, id);
    const snapshot = await getDoc(docRef);
    if (!snapshot.exists()) return null;
    return { id: snapshot.id, ...convertTimestamps(snapshot.data()) } as Evento;
  },

  async create(data: EventoFormData): Promise<string> {
    const docData = {
      ...data,
      coordenadas: data.latitude && data.longitude
        ? { latitude: data.latitude, longitude: data.longitude }
        : null,
      criadoEm: Timestamp.now(),
      dataInicio: Timestamp.fromDate(new Date(data.dataInicio)),
      dataFim: data.dataFim ? Timestamp.fromDate(new Date(data.dataFim)) : null,
    };
    delete (docData as any).latitude;
    delete (docData as any).longitude;
    const docRef = await addDoc(eventosRef, docData);
    return docRef.id;
  },

  async update(id: string, data: Partial<EventoFormData>): Promise<void> {
    const docRef = doc(eventosRef, id);
    const updateData: any = { ...data };
    if (data.latitude !== undefined && data.longitude !== undefined) {
      updateData.coordenadas = { latitude: data.latitude, longitude: data.longitude };
      delete updateData.latitude;
      delete updateData.longitude;
    }
    if (data.dataInicio) {
      updateData.dataInicio = Timestamp.fromDate(new Date(data.dataInicio));
    }
    if (data.dataFim) {
      updateData.dataFim = Timestamp.fromDate(new Date(data.dataFim));
    }
    await updateDoc(docRef, updateData);
  },

  async delete(id: string): Promise<void> {
    const docRef = doc(eventosRef, id);
    await deleteDoc(docRef);
  },
};

// ==================== CÂMERAS ====================
const camerasRef = collection(db, 'cameras');

export const camerasService = {
  async getAll(): Promise<Camera[]> {
    const q = query(camerasRef, orderBy('nome', 'asc'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...convertTimestamps(doc.data()),
    })) as Camera[];
  },

  async getById(id: string): Promise<Camera | null> {
    const docRef = doc(camerasRef, id);
    const snapshot = await getDoc(docRef);
    if (!snapshot.exists()) return null;
    return { id: snapshot.id, ...convertTimestamps(snapshot.data()) } as Camera;
  },

  async create(data: CameraFormData): Promise<string> {
    const docData = {
      ...data,
      coordenadas: { latitude: data.latitude, longitude: data.longitude },
      atualizadoEm: Timestamp.now(),
    };
    delete (docData as any).latitude;
    delete (docData as any).longitude;
    const docRef = await addDoc(camerasRef, docData);
    return docRef.id;
  },

  async update(id: string, data: Partial<CameraFormData>): Promise<void> {
    const docRef = doc(camerasRef, id);
    const updateData: any = { ...data, atualizadoEm: Timestamp.now() };
    if (data.latitude !== undefined && data.longitude !== undefined) {
      updateData.coordenadas = { latitude: data.latitude, longitude: data.longitude };
      delete updateData.latitude;
      delete updateData.longitude;
    }
    await updateDoc(docRef, updateData);
  },

  async delete(id: string): Promise<void> {
    const docRef = doc(camerasRef, id);
    await deleteDoc(docRef);
  },

  async updateStatus(id: string, status: Camera['status']): Promise<void> {
    const docRef = doc(camerasRef, id);
    await updateDoc(docRef, { status, atualizadoEm: Timestamp.now() });
  },
};

// ==================== NOTÍCIAS ====================
const noticiasRef = collection(db, 'noticias');

export const noticiasService = {
  async getAll(): Promise<Noticia[]> {
    const q = query(noticiasRef, orderBy('publicadoEm', 'desc'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...convertTimestamps(doc.data()),
    })) as Noticia[];
  },

  async getById(id: string): Promise<Noticia | null> {
    const docRef = doc(noticiasRef, id);
    const snapshot = await getDoc(docRef);
    if (!snapshot.exists()) return null;
    return { id: snapshot.id, ...convertTimestamps(snapshot.data()) } as Noticia;
  },

  async create(data: NoticiaFormData): Promise<string> {
    const docData = {
      ...data,
      criadoEm: Timestamp.now(),
      publicadoEm: data.publicadoEm
        ? Timestamp.fromDate(new Date(data.publicadoEm))
        : Timestamp.now(),
    };
    const docRef = await addDoc(noticiasRef, docData);
    return docRef.id;
  },

  async update(id: string, data: Partial<NoticiaFormData>): Promise<void> {
    const docRef = doc(noticiasRef, id);
    const updateData: any = { ...data };
    if (data.publicadoEm) {
      updateData.publicadoEm = Timestamp.fromDate(new Date(data.publicadoEm));
    }
    await updateDoc(docRef, updateData);
  },

  async delete(id: string): Promise<void> {
    const docRef = doc(noticiasRef, id);
    await deleteDoc(docRef);
  },

  async toggleAtivo(id: string, ativo: boolean): Promise<void> {
    const docRef = doc(noticiasRef, id);
    await updateDoc(docRef, { ativo });
  },
};

// ==================== BANNERS ====================
const bannersRef = collection(db, 'banners');

export const bannersService = {
  async getAll(): Promise<Banner[]> {
    const q = query(bannersRef, orderBy('ordem', 'asc'));
    const snapshot = await getDocs(q);
    return snapshot.docs.map((doc) => ({
      id: doc.id,
      ...convertTimestamps(doc.data()),
    })) as Banner[];
  },

  async getById(id: string): Promise<Banner | null> {
    const docRef = doc(bannersRef, id);
    const snapshot = await getDoc(docRef);
    if (!snapshot.exists()) return null;
    return { id: snapshot.id, ...convertTimestamps(snapshot.data()) } as Banner;
  },

  async create(data: BannerFormData): Promise<string> {
    const docData = {
      ...data,
      criadoEm: Timestamp.now(),
    };
    const docRef = await addDoc(bannersRef, docData);
    return docRef.id;
  },

  async update(id: string, data: Partial<BannerFormData>): Promise<void> {
    const docRef = doc(bannersRef, id);
    await updateDoc(docRef, data);
  },

  async delete(id: string): Promise<void> {
    const docRef = doc(bannersRef, id);
    await deleteDoc(docRef);
  },

  async toggleAtivo(id: string, ativo: boolean): Promise<void> {
    const docRef = doc(bannersRef, id);
    await updateDoc(docRef, { ativo });
  },
};

// ==================== ESTATÍSTICAS ====================
export const statsService = {
  async getDashboardStats(): Promise<DashboardStats> {
    const [alertas, eventos, cameras, noticias] = await Promise.all([
      alertasService.getAll(),
      eventosService.getAll(),
      camerasService.getAll(),
      noticiasService.getAll(),
    ]);

    const now = new Date();

    return {
      totalAlertas: alertas.length,
      alertasAtivos: alertas.filter((a) => a.ativo).length,
      totalEventos: eventos.length,
      eventosProximos: eventos.filter((e) => new Date(e.dataInicio) >= now).length,
      totalCameras: cameras.length,
      camerasOnline: cameras.filter((c) => c.status === 'online').length,
      totalNoticias: noticias.length,
      noticiasAtivas: noticias.filter((n) => n.ativo).length,
    };
  },
};

// ==================== HELPERS ====================
function convertTimestamps(data: DocumentData): DocumentData {
  const converted: DocumentData = {};
  for (const [key, value] of Object.entries(data)) {
    if (value instanceof Timestamp) {
      converted[key] = value.toDate();
    } else if (value && typeof value === 'object' && !Array.isArray(value)) {
      converted[key] = convertTimestamps(value);
    } else {
      converted[key] = value;
    }
  }
  return converted;
}
