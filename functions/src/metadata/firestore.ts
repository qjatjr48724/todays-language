import { db } from "../shared/firebase";

export const PUBLIC_METADATA_DOC_ID = "countries";

export type CountryMeta = {
  alpha3: string;
  alpha2: string;
  endonym: string;
  enabled: boolean;
  flagUrl?: string;
  flagSource?: "data_go_kr" | "manual" | "unknown";
  updatedAtMs: number;
};

export function publicCountriesRef() {
  return db.collection("public_metadata").doc(PUBLIC_METADATA_DOC_ID).collection("items");
}

