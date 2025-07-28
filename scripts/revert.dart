import 'dart:io';

import 'history_manager.dart';

/// 撤回脚本
/// 使用方法:
/// dart run scripts/revert.dart           # 显示历史记录并选择撤回
/// dart run scripts/revert.dart --list    # 只显示历史记录
/// dart run scripts/revert.dart --clear   # 清空历史记录
/// dart run scripts/revert.dart <id>      # 直接撤回指定ID的操作
void main(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    _showHelp();
    return;
  }

  if (arguments.contains('--clear')) {
    await _clearHistory();
    return;
  }

  if (arguments.contains('--list')) {
    await _showHistory();
    return;
  }

  if (arguments.isNotEmpty && !arguments[0].startsWith('--')) {
    // 直接撤回指定ID的操作
    await _revertById(arguments[0]);
    return;
  }

  // 默认显示历史记录并交互式选择
  await _interactiveRevert();
}

/// 显示帮助信息
void _showHelp() {
  print('''
🔄 撤回工具使用说明
==================

用法:
  dart run scripts/revert.dart           # 交互式撤回
  dart run scripts/revert.dart --list    # 显示历史记录
  dart run scripts/revert.dart --clear   # 清空历史记录
  dart run scripts/revert.dart <id>      # 撤回指定操作

选项:
  -h, --help     显示此帮助信息
  --list         仅显示历史记录，不执行撤回
  --clear        清空所有历史记录
  <id>           直接撤回指定ID的操作

示例:
  dart run scripts/revert.dart --list
  dart run scripts/revert.dart 1640995200000
''');
}

/// 显示历史记录
Future<void> _showHistory() async {
  final history = await HistoryManager.getHistory();
  print(HistoryManager.formatHistory(history));
}

/// 清空历史记录
Future<void> _clearHistory() async {
  print('⚠️  确定要清空所有历史记录吗？(y/N)');
  final input = stdin.readLineSync()?.toLowerCase();

  if (input == 'y' || input == 'yes') {
    await HistoryManager.clearHistory();
  } else {
    print('❌ 操作已取消');
  }
}

/// 根据ID撤回操作
Future<void> _revertById(String operationId) async {
  print('🔄 正在撤回操作: $operationId');
  final success = await HistoryManager.revertOperation(operationId);

  if (!success) {
    exit(1);
  }
}

/// 交互式撤回
Future<void> _interactiveRevert() async {
  final history = await HistoryManager.getHistory();

  if (history.isEmpty) {
    print('📝 暂无可撤回的操作记录');
    return;
  }

  print(HistoryManager.formatHistory(history));
  print('请选择要撤回的操作 (输入序号1-${history.length}，或输入q退出):');

  final input = stdin.readLineSync()?.trim();

  if (input == null || input.toLowerCase() == 'q') {
    print('❌ 操作已取消');
    return;
  }

  final index = int.tryParse(input);
  if (index == null || index < 1 || index > history.length) {
    print('❌ 无效的序号，请输入1-${history.length}之间的数字');
    return;
  }

  final operation = history[index - 1];
  final operationId = operation['id'];
  final operationType = operation['type'];
  final operationName = operation['name'];

  print('');
  print('📋 将要撤回的操作:');
  print('   类型: ${operationType.toUpperCase()}');
  print('   名称: $operationName');
  print('   创建文件: ${operation['createdFiles'].length} 个');
  print('   修改文件: ${operation['modifiedFiles'].length} 个');
  print('');
  print('⚠️  确定要撤回此操作吗？(y/N)');

  final confirmation = stdin.readLineSync()?.toLowerCase();

  if (confirmation == 'y' || confirmation == 'yes') {
    print('');
    print('🔄 正在撤回操作...');
    final success = await HistoryManager.revertOperation(operationId);

    if (!success) {
      exit(1);
    }
  } else {
    print('❌ 操作已取消');
  }
}
