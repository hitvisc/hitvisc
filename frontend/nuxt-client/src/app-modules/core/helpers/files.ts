import axios from 'axios';
import { ComposerTranslation } from 'vue-i18n';

export function parseUploadFileErrorMessage(error: unknown, t: ComposerTranslation) {
  if (axios.isAxiosError(error)) {
    const { response } = error;
    const { errorCode } = response?.data ?? {};
    if (errorCode) {
      return t(`files.errorCode.${errorCode}`) || t('files.errorCode.unknownUploadError');
    }
  }
  return t('files.errorCode.unknownUploadError');
}
