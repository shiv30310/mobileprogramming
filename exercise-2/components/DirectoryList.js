import React, { useState, useEffect, useCallback } from 'react';
import { View, FlatList, StyleSheet, Text, TouchableOpacity } from 'react-native';
import { FAB, Dialog, Portal, Button, TextInput, IconButton } from 'react-native-paper';
import DirectoryService from '../services/DirectoryService';

const DirectoryList = ({ navigation }) => {
  const [directories, setDirectories] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [visible, setVisible] = useState(false);
  const [editVisible, setEditVisible] = useState(false);
  const [name, setName] = useState('');
  const [editingId, setEditingId] = useState(null);
  const [deleteVisible, setDeleteVisible] = useState(false);
  const [deleteId, setDeleteId] = useState(null);

  const loadDirectories = useCallback(async () => {
    const dirs = await DirectoryService.getAll();
    setDirectories(dirs);
  }, []);

  useEffect(() => {
    loadDirectories();
  }, [loadDirectories]);

  const handleCreate = async () => {
    if (name.trim()) {
      await DirectoryService.create(name);
      setName('');
      setVisible(false);
      loadDirectories();
    }
  };

  const handleUpdate = async () => {
    if (name.trim() && editingId) {
      await DirectoryService.update(editingId, { name });
      setName('');
      setEditingId(null);
      setEditVisible(false);
      loadDirectories();
    }
  };

  const handleDelete = async () => {
    if (deleteId) {
      await DirectoryService.delete(deleteId);
      setDeleteId(null);
      setDeleteVisible(false);
      loadDirectories();
    }
  };

  const openEditDialog = (directory) => {
    setName(directory.name);
    setEditingId(directory.id);
    setEditVisible(true);
  };

  const openDeleteDialog = (id) => {
    setDeleteId(id);
    setDeleteVisible(true);
  };

  const filteredDirectories = directories.filter(dir =>
    dir.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const renderDirectoryItem = ({ item }) => (
    <View style={styles.folderItem}>
      <TouchableOpacity
        style={{ flex: 1 }}
        onPress={() => navigation.navigate('Messages', { directory: item })}
        activeOpacity={0.7}
      >
        <Text style={styles.folderName}>{item.name}</Text>
      </TouchableOpacity>

      <IconButton
        icon="pencil"
        size={20}
        color="#388e3c"
        onPress={() => openEditDialog(item)}
      />

      <IconButton
        icon="delete"
        size={20}
        color="red"
        onPress={() => openDeleteDialog(item.id)}
      />
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Directories</Text>

      <TextInput
        placeholder="Search directories..."
        value={searchQuery}
        onChangeText={setSearchQuery}
        mode="outlined"
        style={styles.searchInput}
        theme={{
          colors: {
            primary: '#388e3c',
            outline: '#66bb6a'
          }
        }}
      />

      <FlatList
        data={filteredDirectories}
        renderItem={renderDirectoryItem}
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
          <Dialog.Title style={styles.dialogTitle}>New Directory</Dialog.Title>
          <Dialog.Content>
            <TextInput
    label="Directory Name"
  value={name}
  onChangeText={setName}
  style={styles.input}
  mode="flat" // or "outlined"
  theme={{
    colors: {
      primary: '#388e3c',  // This controls label text & active underline/border color (green)
 
      placeholder: '#388e3c', // label placeholder color when not focused (optional)
      text: '#388e3c', // input text color
    },
  }}
              
            />
          </Dialog.Content>
          <Dialog.Actions>
            <Button 
            mode='text'
            labelStyle={{ color: '#388e3c' }}
            onPress={() => setVisible(false)}>
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
          <Dialog.Title style={styles.dialogTitle}>Edit Directory</Dialog.Title>
          <Dialog.Content>
            <TextInput
              label="Directory Name"
              value={name}
              onChangeText={setName}
              style={styles.input}
            />
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setEditVisible(false)} textColor="#6C63FF">
              Cancel
            </Button>
            <Button onPress={handleUpdate} textColor="#6C63FF">
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
            <Text>Are you sure you want to delete this directory?</Text>
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setDeleteVisible(false)} textColor="#6C63FF">
              Cancel
            </Button>
            <Button onPress={handleDelete} textColor="#FF6584">
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
    backgroundColor: '#e8f5e9',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
    color: '#388e3c',
  },
  searchInput: {
    marginBottom: 16,
    backgroundColor: 'white',
    borderColor: '#388e3c',
  },
  listContent: {
    paddingBottom: 20,
  },
  folderItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'white',
    padding: 15,
    marginBottom: 10,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#66bb6a',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  folderName: {
    fontSize: 18,
    fontWeight: '600',
  },
  fab: {
    position: 'absolute',
    margin: 16,
    right: 0,
    bottom: 0,
    backgroundColor: '#66bb6a',
  },
  dialogTitle: {
    color: '#388e3c',
  },
  input: {
    borderBottomColor: '#000',
    underlineColorAndroid: '#388e3c',
    borderColor:'green'
  },
});

export default DirectoryList;
