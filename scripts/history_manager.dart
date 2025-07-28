import 'dart:io';
import 'dart:convert';

/// 操作历史记录管理器
class HistoryManager {
  static const String _historyFile = '.generator_history.json';

  /// 获取历史记录文件路径
  static String get historyPath => _historyFile;

  /// 记录生成操作
  static Future<void> recordGeneration({
    required String type, // 'page' 或 'service'
    required String name,
    required List<String> createdFiles,
    required Map<String, String> modifiedFiles, // 文件路径 -> 原始内容
    Map<String, dynamic>? metadata,
  }) async {
    final history = await _loadHistory();

    final operation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': type,
      'name': name,
      'timestamp': DateTime.now().toIso8601String(),
      'createdFiles': createdFiles,
      'modifiedFiles': modifiedFiles,
      'metadata': metadata ?? {},
    };

    history.insert(0, operation); // 最新的操作放在前面

    // 只保留最近20次操作
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }

    await _saveHistory(history);
  }

  /// 获取历史记录
  static Future<List<Map<String, dynamic>>> getHistory() async {
    return await _loadHistory();
  }

  /// 撤回指定操作
  static Future<bool> revertOperation(String operationId) async {
    final history = await _loadHistory();
    final operationIndex = history.indexWhere((op) => op['id'] == operationId);

    if (operationIndex == -1) {
      print('❌ 未找到指定的操作记录');
      return false;
    }

    final operation = history[operationIndex];

    try {
      // 删除创建的文件
      final createdFiles = List<String>.from(operation['createdFiles'] ?? []);
      for (final filePath in createdFiles) {
        final file = File(filePath);
        if (file.existsSync()) {
          await file.delete();
          print('🗑️  删除文件: $filePath');
        }
      }

      // 恢复修改的文件
      final modifiedFiles = Map<String, String>.from(
        operation['modifiedFiles'] ?? {},
      );
      for (final entry in modifiedFiles.entries) {
        final file = File(entry.key);
        if (entry.value.isEmpty) {
          // 如果原始内容为空，说明文件是新创建的，应该删除
          if (file.existsSync()) {
            await file.delete();
            print('🗑️  删除文件: ${entry.key}');
          }
        } else {
          // 恢复文件内容
          await file.writeAsString(entry.value);
          print('↩️  恢复文件: ${entry.key}');
        }
      }

      // 清理空目录
      await _cleanupEmptyDirectories(createdFiles);

      // 从历史记录中移除该操作
      history.removeAt(operationIndex);
      await _saveHistory(history);

      print('✅ 操作撤回成功!');
      return true;
    } catch (e) {
      print('❌ 撤回操作失败: $e');
      return false;
    }
  }

  /// 清空历史记录
  static Future<void> clearHistory() async {
    final file = File(_historyFile);
    if (file.existsSync()) {
      await file.delete();
    }
    print('🧹 历史记录已清空');
  }

  /// 加载历史记录
  static Future<List<Map<String, dynamic>>> _loadHistory() async {
    final file = File(_historyFile);
    if (!file.existsSync()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      final List<dynamic> data = json.decode(content);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('⚠️  读取历史记录失败: $e');
      return [];
    }
  }

  /// 保存历史记录
  static Future<void> _saveHistory(List<Map<String, dynamic>> history) async {
    final file = File(_historyFile);
    final content = json.encode(history);
    await file.writeAsString(content);
  }

  /// 清理空目录
  static Future<void> _cleanupEmptyDirectories(List<String> filePaths) async {
    final directories = <String>{};

    // 收集所有可能的父目录
    for (final filePath in filePaths) {
      var dir = File(filePath).parent;
      while (dir.path != '.' && dir.path != dir.parent.path) {
        directories.add(dir.path);
        dir = dir.parent;
      }
    }

    // 从最深的目录开始清理
    final sortedDirs = directories.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final dirPath in sortedDirs) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        try {
          final entities = dir.listSync();
          if (entities.isEmpty) {
            await dir.delete();
            print('📁 删除空目录: $dirPath');
          }
        } catch (e) {
          // 忽略删除目录失败的错误
        }
      }
    }
  }

  /// 格式化历史记录显示
  static String formatHistory(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return '📝 暂无操作历史';
    }

    final buffer = StringBuffer();
    buffer.writeln('📋 操作历史记录:');
    buffer.writeln('${'=' * 50}');

    for (int i = 0; i < history.length; i++) {
      final operation = history[i];
      final timestamp = DateTime.parse(operation['timestamp']);
      final timeStr =
          '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

      buffer.writeln(
        '${i + 1}. [${operation['id']}] ${operation['type'].toUpperCase()}: ${operation['name']}',
      );
      buffer.writeln('   时间: $timeStr');
      buffer.writeln('   创建文件: ${operation['createdFiles'].length} 个');
      buffer.writeln('   修改文件: ${operation['modifiedFiles'].length} 个');
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
