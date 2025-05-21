class DirectoryService {
  constructor() {
    this.directories = [
      {
        id: '1',
        name: 'Work',
        createdAt: new Date(),
        isFavorite: false,
        messages: ['Meeting at 3 PM', 'Project deadline extended'],
      },
      {
        id: '2',
        name: 'Personal',
        createdAt: new Date(),
        isFavorite: true,
        messages: ['Buy groceries', 'Call mom'],
      },
      {
        id: '3',
        name: 'Ideas',
        createdAt: new Date(),
        isFavorite: false,
        messages: ['App idea: AI tutor'],
      },
      {
        id: '4',
        name: 'Travel',
        createdAt: new Date(),
        isFavorite: false,
        messages: [],
      },
    ];
  }

  getAll() {
    return Promise.resolve(
      this.directories.map(dir => ({
        ...dir,
        messageCount: dir.messages.length,
      }))
    );
  }

  create(name) {
    const newDirectory = {
      id: Date.now().toString(),
      name,
      createdAt: new Date(),
      isFavorite: false,
      messages: [],
    };
    this.directories.push(newDirectory);
    return Promise.resolve({ ...newDirectory, messageCount: 0 });
  }

  update(id, updates) {
    const index = this.directories.findIndex(dir => dir.id === id);
    if (index !== -1) {
      this.directories[index] = {
        ...this.directories[index],
        ...updates,
      };
      return Promise.resolve({
        ...this.directories[index],
        messageCount: this.directories[index].messages.length,
      });
    }
    return Promise.reject(new Error('Directory not found'));
  }

  delete(id) {
    const index = this.directories.findIndex(dir => dir.id === id);
    if (index !== -1) {
      const deleted = this.directories.splice(index, 1);
      return Promise.resolve({
        ...deleted[0],
        messageCount: deleted[0].messages.length,
      });
    }
    return Promise.reject(new Error('Directory not found'));
  }

  toggleFavorite(id) {
    const index = this.directories.findIndex(dir => dir.id === id);
    if (index !== -1) {
      this.directories[index].isFavorite = !this.directories[index].isFavorite;
      return Promise.resolve({
        ...this.directories[index],
        messageCount: this.directories[index].messages.length,
      });
    }
    return Promise.reject(new Error('Directory not found'));
  }

  getFavorites() {
    return Promise.resolve(
      this.directories
        .filter(dir => dir.isFavorite)
        .map(dir => ({
          ...dir,
          messageCount: dir.messages.length,
        }))
    );
  }

  // NEW: Add message to a directory
  addMessage(directoryId, message) {
    const index = this.directories.findIndex(dir => dir.id === directoryId);
    if (index !== -1) {
      this.directories[index].messages.push(message);
      return Promise.resolve({
        ...this.directories[index],
        messageCount: this.directories[index].messages.length,
      });
    }
    return Promise.reject(new Error('Directory not found'));
  }

  // NEW: Remove message from a directory by index
  removeMessage(directoryId, messageIndex) {
    const index = this.directories.findIndex(dir => dir.id === directoryId);
    if (index !== -1) {
      if (
        messageIndex >= 0 &&
        messageIndex < this.directories[index].messages.length
      ) {
        this.directories[index].messages.splice(messageIndex, 1);
        return Promise.resolve({
          ...this.directories[index],
          messageCount: this.directories[index].messages.length,
        });
      }
      return Promise.reject(new Error('Message index out of range'));
    }
    return Promise.reject(new Error('Directory not found'));
  }
}

export default new DirectoryService();
