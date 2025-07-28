import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/index.dart';
import 'index.dart';

/// 首页视图
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  /// 构建主视图
  Widget _buildView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildFeaturesList(),
          const SizedBox(height: 20),
          _buildQuickStart(),
          const SizedBox(height: 20),
          _buildLanguageSection(),
        ],
      ),
    );
  }

  /// 构建欢迎卡片
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.rocket_launch, size: 32, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'home_title'.tr,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'home_description'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                '${'home_counter'.tr}: ${controller.count}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: controller.increment,
              icon: const Icon(Icons.add),
              label: Text('home_increment'.tr),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建特性列表
  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.widgets,
        'title': 'feature_getx',
        'desc': 'feature_getx_desc',
      },
      {
        'icon': Icons.architecture,
        'title': 'feature_mvc',
        'desc': 'feature_mvc_desc',
      },
      {
        'icon': Icons.route,
        'title': 'feature_router',
        'desc': 'feature_router_desc',
      },
      {
        'icon': Icons.build,
        'title': 'feature_generator',
        'desc': 'feature_generator_desc',
      },
      {
        'icon': Icons.http,
        'title': 'feature_http',
        'desc': 'feature_http_desc',
      },
      {
        'icon': Icons.storage,
        'title': 'feature_storage',
        'desc': 'feature_storage_desc',
      },
      {
        'icon': Icons.language,
        'title': 'feature_i18n',
        'desc': 'feature_i18n_desc',
      },
      {
        'icon': Icons.undo,
        'title': 'feature_revert',
        'desc': 'feature_revert_desc',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'home_features_title'.tr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => ListTile(
                leading: Icon(feature['icon'] as IconData, color: Colors.blue),
                title: Text((feature['title'] as String).tr),
                subtitle: Text((feature['desc'] as String).tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建快速开始
  Widget _buildQuickStart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'home_quick_start_title'.tr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCommandTile(
              'generate_page'.tr,
              'generate_page_cmd'.tr,
              'generate_page_desc'.tr,
            ),
            _buildCommandTile(
              'generate_service'.tr,
              'generate_service_cmd'.tr,
              'generate_service_desc'.tr,
            ),
            _buildCommandTile(
              'scan_routes'.tr,
              'scan_routes_cmd'.tr,
              'scan_routes_desc'.tr,
            ),
            _buildCommandTile(
              'revert_operation'.tr,
              'revert_operation_cmd'.tr,
              'revert_operation_desc'.tr,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建语言设置区域
  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.language, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'home_language'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children: LanguageService.to
                    .getLanguageOptions()
                    .map(
                      (option) => RadioListTile<String>(
                        title: Text(option['name']),
                        subtitle: Text(option['code']),
                        value: option['code'],
                        groupValue: LanguageService.to.currentLanguageCode,
                        onChanged: (value) async {
                          if (value != null) {
                            final locale = AppLocales.getLocaleFromCode(value);
                            if (locale != null) {
                              await LanguageService.to.changeLanguage(locale);
                              Get.snackbar(
                                'info'.tr,
                                'language_changed'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                              );
                            }
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await LanguageService.to.switchToNextLanguage();
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: Text('next'.tr),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await LanguageService.to.resetToSystemLanguage();
                  },
                  icon: const Icon(Icons.phone_android),
                  label: const Text('System'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建命令行示例
  Widget _buildCommandTile(String title, String command, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              command,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      id: "home",
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text('home_title'.tr),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.language),
                onPressed: () async {
                  await LanguageService.to.switchToNextLanguage();
                },
                tooltip: 'home_language'.tr,
              ),
            ],
          ),
          body: SafeArea(child: _buildView()),
        );
      },
    );
  }
}
