class MessageService {
  constructor() {
    this.messages = {
      '1': [
        { id: '101', text: 'Complete project', createdAt: new Date() },
        { id: '102', text: 'Meeting at 3 PM', createdAt: new Date() },
      ],
      '2': [
        { id: '201', text: 'Buy groceries', createdAt: new Date() },
      ],
    };
  }

  getAll(directoryId) {
    return Promise.resolve([...(this.messages[directoryId] || [])]);
  }

  create(directoryId, text) {
    if (!this.messages[directoryId]) {
      this.messages[directoryId] = [];
    }
    
    const newMessage = {
      id: Date.now().toString(),
      text,
      createdAt: new Date(),
    };
    
    this.messages[directoryId].push(newMessage);
    return Promise.resolve(newMessage);
  }

  update(directoryId, messageId, text) {
    if (!this.messages[directoryId]) {
      return Promise.reject(new Error('Directory not found'));
    }
    
    const index = this.messages[directoryId].findIndex(msg => msg.id === messageId);
    if (index !== -1) {
      this.messages[directoryId][index] = { 
        ...this.messages[directoryId][index], 
        text 
      };
      return Promise.resolve(this.messages[directoryId][index]);
    }
    return Promise.reject(new Error('Message not found'));
  }

  delete(directoryId, messageId) {
    if (!this.messages[directoryId]) {
      return Promise.reject(new Error('Directory not found'));
    }
    
    const index = this.messages[directoryId].findIndex(msg => msg.id === messageId);
    if (index !== -1) {
      const deleted = this.messages[directoryId].splice(index, 1);
      return Promise.resolve(deleted[0]);
    }
    return Promise.reject(new Error('Message not found'));
  }
}

export default new MessageService();