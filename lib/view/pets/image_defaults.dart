String getDefaultImage(String? breed, String? color) {
  if (breed == null || breed.isEmpty) {
    return 'assets/icons/default-pet.png'; // Generic default
  }
  breed = breed.toLowerCase();
  color = color?.toLowerCase() ?? 'other'; // Handle null color

  Map<String, Map<String, String>> defaultImages = {
    'dachshund': {
      'black': 'assets/dogs/dachshund.png',
      'brown': 'assets/dogs/dachshund-brown-ally.png',
    },
    'labrador': {
      'black': 'assets/dogs/black-labrador-cody.png',
      'brown': 'assets/dogs/black-labrador-brown.png',
      'light': 'assets/dogs/labrador-light.png',
    },
    'golden retriever': {
      'brown': 'assets/dogs/becky-golden-retriever.png',
      'light': 'assets/dogs/golden-retriever-light.png',
    },
    'japanese bobtail': {
      'black': 'assets/cats/jp-cat-bobtail-comet.png',
      'light': 'assets/cats/japanese-bobtail-cat.png',
    },
    'ragdoll': {
      'light': 'assets/cats/ragdoll-cat.png',
      'other': 'assets/cats/ragdoll-cat.png',
    },
    'german shepherd': {
      'other': 'assets/dogs/german-shepherd.png',
    },
  };

  return defaultImages[breed]?[color] ??
      defaultImages[breed]?['other'] ??
      'assets/together.png';
}