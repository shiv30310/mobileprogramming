import React, { useState, useEffect, useCallback } from 'react';
import { View, FlatList, StyleSheet, Text } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { FAB, Dialog, Portal, Button, TextInput } from 'react-native-paper';
import MessageService from '../services/MessageService';

const MessageList = ({ route, navigation }) => {
  const { directory } = route.params;
  const [messages, setMessages] = useState([]);
  const [visible, setVisible] = useState(false);
  const [editVisible, setEditVisible] = useState(false);
  const [text, setText] = useState('');
  const [editingId, setEditingId] = useState(null);
  const [deleteVisible, setDeleteVisible] = useState(false);
  const [deleteId, setDeleteId] = useState(null);

  const loadMessages = useCallback(async () => {
    const msgs = await MessageService.getAll(directory.id);
    setMessages(msgs);
  }, [directory.id]);

  useEffect(() => {
    loadMessages();
  }, [loadMessages]);

  const handleCreate = async () => {
    if (text.trim()) {
      await MessageService.create(directory.id, text);
      setText('');
      setVisible(false);
      loadMessages();
    }
  };

  const handleUpdate = async () => {
    if (text.trim() && editingId) {
      await MessageService.update(directory.id, editingId, text);
      setText('');
      setEditingId(null);
      setEditVisible(false);
      loadMessages();
    }
  };

  const handleDelete = async () => {
    if (deleteId) {
      await MessageService.delete(directory.id, deleteId);
      setDeleteId(null);
      setDeleteVisible(false);
      loadMessages();
    }
  };

  const openEditDialog = (message) => {
    setText(message.text);
    setEditingId(message.id);
    setEditVisible(true);
  };

  const openDeleteDialog = (id) => {
    setDeleteId(id);
    setDeleteVisible(true);
  };

  const renderMessageItem = ({ item }) => (
    <TouchableOpacity
      style={[
        styles.messageItem,
        item.important && styles.importantMessage
      ]}
    >
      <View style={styles.messageContent}>
        <Text style={styles.messageText}>{item.text}</Text>
        <Text style={styles.messageDate}>
          {new Date(item.createdAt).toLocaleDateString()}
        </Text>
      </View>
      <View style={styles.messageActions}>
        <Button 
       mode='text'
            labelStyle={{ color: '#388e3c' }}
          onPress={() => openEditDialog(item)}
          compact
        >
          Edit
        </Button>
        <Button 
          mode='text'
            labelStyle={{ color: '#388e3c' }}
          onPress={() => openDeleteDialog(item.id)}
          compact
        >
          Delete
        </Button>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{directory.name}</Text>
      
      <FlatList
        data={messages}
        renderItem={renderMessageItem}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.listContent}
      />

      <FAB
        style={styles.fab}
        icon="plus"
        onPress={() => setVisible(true)}
        color="white"
      />

      {/* Create Dialog */}
      <Portal>
        <Dialog visible={visible} onDismiss={() => setVisible(false)}>
          <Dialog.Title style={styles.dialogTitle}>New Message</Dialog.Title>
          <Dialog.Content>
            <TextInput
              label="Message Text"
              value={text}
              onChangeText={setText}
              style={styles.input}
              mode="flat" // or "outlined"
  theme={{
    colors: {
      primary: '#388e3c',  // This controls label text & active underline/border color (green)
 
      placeholder: '#388e3c', // label placeholder color when not focused (optional)
      text: '#388e3c', // input text color
    },
  }}
              multiline
            />
          </Dialog.Content>
          <Dialog.Actions>
            <Button 
            mode='text'
            labelStyle={{ color: '#388e3c' }}
            onPress={() => setVisible(false)} >
              Cancel
            </Button>
            <Button 
            mode='text'
            labelStyle={{ color: '#388e3c' }}
            onPress={handleCreate}>
              Create
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>

      {/* Edit Dialog */}
      <Portal>
        <Dialog visible={editVisible} onDismiss={() => setEditVisible(false)}>
          <Dialog.Title style={styles.dialogTitle}>Edit Message</Dialog.Title>
          <Dialog.Content>
            <TextInput
              label="Message Text"
              value={text}
              onChangeText={setText}
              style={styles.input}
              multiline
            />
          </Dialog.Content>
          <Dialog.Actions>
            <Button 
            mode='text'
            labelStyle={{ color: '#388e3c' }}
            onPress={() => setEditVisible(false)} >
              Cancel
            </Button>

            <Button 
            mode='text'
            labelStyle={{ color: '#388e3c' }}
            onPress={handleUpdate} 
         >
              Save
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>

      {/* Delete Dialog */}
      <Portal>
        <Dialog visible={deleteVisible} onDismiss={() => setDeleteVisible(false)}>
          <Dialog.Title style={styles.dialogTitle}>Confirm Delete</Dialog.Title>
          <Dialog.Content>
            <Text>Are you sure you want to delete this message?</Text>
          </Dialog.Content>
          <Dialog.Actions>
            <Button 
            mode='text'
            labelStyle={{ color: '#388e3c' }}
            onPress={() => setDeleteVisible(false)} >
              Cancel
            </Button>
            <Button 
            mode='text'
            labelStyle={{ color: '#388e3c' }}
            onPress={handleDelete} >
              Delete
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#e8f5e9' // light green background
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#388e3c' // dark green title
  },
  listContent: {
    paddingBottom: 20
  },
  messageItem: {
    backgroundColor: 'white',
    padding: 15,
    marginBottom: 10,
    borderRadius: 8,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3 // Android shadow
  },
  importantMessage: {
    borderLeftWidth: 4,
    borderLeftColor: '#66bb6a' // light green border for important
  },
  messageContent: {
    flex: 1
  },
  messageText: {
    fontSize: 16
  },
  messageDate: {
    color: 'gray',
    marginTop: 5,
    fontSize: 12
  },
  messageActions: {
    flexDirection: 'row',

  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
    backgroundColor: '#66bb6a' // light green FAB
  },
  dialogTitle: {
    color: '#388e3c' // dark green dialog title
  },
  input: {
    backgroundColor: 'white'
  },
  buttons: {
    textColor: '#388e3c',
    color: 'green'
  }
});


export default MessageList;