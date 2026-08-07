/** DL-01 랜덤 단어 이미지 생성용 카탈로그 (풀 JSON에서 추출). */

export type RandomWordImageCatalogItem = {
  id: string;
  conceptEn: string;
  imagePrompt: string | null;
};

export const DL01_IMAGE_PROMPT_TEMPLATE = "Warm educational flashcard illustration of: {conceptEn}. Show a clear everyday scene with simple friendly people (full body or upper body), natural gestures, soft pastel colors, and a soft cream background. Gentle expressive faces are OK. Keep the composition readable for language learning. Strictly no text, no letters, no words, no labels, no watermark.";

export const DL01_IMAGE_ITEMS: RandomWordImageCatalogItem[] = [
  {
    "id": "dl01_001",
    "conceptEn": "two friends facing each other outdoors and waving hi casually",
    "imagePrompt": null
  },
  {
    "id": "dl01_004",
    "conceptEn": "two people greeting each other in the morning, with a large bright rising sun clearly visible in the sky behind them",
    "imagePrompt": null
  },
  {
    "id": "dl01_005",
    "conceptEn": "two people greeting each other in the afternoon, with a high bright midday sun clearly visible in the sky behind them",
    "imagePrompt": null
  },
  {
    "id": "dl01_006",
    "conceptEn": "two people greeting each other at dusk, with a crescent moon and soft evening sky clearly visible behind them",
    "imagePrompt": null
  },
  {
    "id": "dl01_007",
    "conceptEn": "two people meeting for the first time and shaking hands warmly",
    "imagePrompt": null
  },
  {
    "id": "dl01_008",
    "conceptEn": "two people introducing themselves politely with a friendly bow",
    "imagePrompt": null
  },
  {
    "id": "dl01_009",
    "conceptEn": "a person politely bowing and asking another person for kindness",
    "imagePrompt": null
  },
  {
    "id": "dl01_010",
    "conceptEn": "two friends reuniting happily after a long time apart",
    "imagePrompt": null
  },
  {
    "id": "dl01_012",
    "conceptEn": "two friends chatting and asking how each other has been",
    "imagePrompt": null
  },
  {
    "id": "dl01_013",
    "conceptEn": "two people talking casually about how life has been lately",
    "imagePrompt": null
  },
  {
    "id": "dl01_014",
    "conceptEn": "two people smiling and greeting each other gladly",
    "imagePrompt": null
  },
  {
    "id": "dl01_015",
    "conceptEn": "a cheerful reunion between two smiling people",
    "imagePrompt": null
  },
  {
    "id": "dl01_016",
    "conceptEn": "clear farewell parting: one person stays near a doorway while the other walks away and looks back waving goodbye; show leaving, not a hello meeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_017",
    "conceptEn": "clear farewell parting: two people a short distance apart, one already turning to leave and waving back while walking away, the other waving goodbye; not a hello greeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_018",
    "conceptEn": "clear casual goodbye: one friend already walking away half-turned, the other waves bye; parting scene not meeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_019",
    "conceptEn": "clear farewell at night: a person waves as a friend walks away toward home, with a small moon in the sky; parting not greeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_020",
    "conceptEn": "clear farewell: a caring person waves while a friend walks away carefully into the distance; parting not a hello",
    "imagePrompt": null
  },
  {
    "id": "dl01_021",
    "conceptEn": "clear goodbye parting: two people waving as one walks away, looking forward to next time; show farewell not meeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_022",
    "conceptEn": "clear parting farewell: two friends wave see-you-again as one turns and walks away; not a reunion greeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_023",
    "conceptEn": "clear goodbye: two people wave farewell as one leaves, with tomorrow meeting implied; parting not hello",
    "imagePrompt": null
  },
  {
    "id": "dl01_024",
    "conceptEn": "clear brief parting: two people wave see-you-later as one starts walking away; farewell not meeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_028",
    "conceptEn": "clear farewell: one person leaves and waves while the other stays put wishing them well; parting not greeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_029",
    "conceptEn": "clear caring farewell: people parting with a warm goodbye gesture wishing good health as one walks away",
    "imagePrompt": null
  },
  {
    "id": "dl01_030",
    "conceptEn": "clear caring goodbye: a warm farewell gesture as one person leaves and the other stays, telling them to take care",
    "imagePrompt": null
  },
  {
    "id": "dl01_031",
    "conceptEn": "clear daytime farewell: people parting cheerfully with a goodbye wave wishing a nice day as one walks away",
    "imagePrompt": null
  },
  {
    "id": "dl01_032",
    "conceptEn": "clear weekend farewell: friends wave goodbye as one leaves before the weekend; parting not meeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_033",
    "conceptEn": "clear pleasant farewell: a warm goodbye as one person walks away wishing the other a pleasant day",
    "imagePrompt": null
  },
  {
    "id": "dl01_034",
    "conceptEn": "clear parting: one person walks away making a phone-call gesture meaning they will contact later; farewell not hello",
    "imagePrompt": null
  },
  {
    "id": "dl01_035",
    "conceptEn": "clear parting: one person leaves while asking the other to keep in touch with a phone gesture; farewell not meeting",
    "imagePrompt": null
  },
  {
    "id": "dl01_037",
    "conceptEn": "clear travel goodbye: someone waves farewell as a traveler with luggage walks away to depart; parting not meeting",
    "imagePrompt": null
  }
];

