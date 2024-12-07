import { singleton } from 'tsyringe';
import axios, { Axios, type AxiosRequestConfig } from 'axios';

singleton();
export class HttpConnection {
  constructor() {
    this.http = axios.create({
      baseURL: useRuntimeConfig().public.apiBoincaasBaseUrl,
    });
  }

  private http: Axios;

  getUri() {
    return this.http.getUri();
  }

  async executeRequest(options: AxiosRequestConfig): Promise<{ [key: string]: any }> {
    const _result = await this.http.request(options);
    return _result.data;
  }
}
