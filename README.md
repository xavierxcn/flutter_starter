# Flutter Starter 📱

一个功能完整的Flutter项目脚手架，集成了GetX状态管理、完善的项目结构和代码生成工具，让你快速启动新的Flutter项目。

## ✨ 特性

- 🎯 **GetX状态管理**: 完整的状态管理解决方案
- 🏗️ **MVC架构**: 清晰的代码分层结构
- 🔄 **路由管理**: 统一的路由名称和页面管理
- 🛠️ **代码生成**: 自动生成页面、服务和模型代码
- 📦 **模块化设计**: 良好的模块分离和依赖管理
- 🌐 **HTTP服务**: 集成Dio的网络请求服务
- 💾 **本地存储**: SharedPreferences封装
- 📱 **响应式UI**: Material Design 3支持
- 📄 **模板分离**: 代码模板与脚本分离，易于自定义
- 🎯 **最小示例**: 精简的脚手架结构，快速上手
- ↩️ **操作撤回**: 支持撤回错误的生成操作，避免手动清理
- 🌐 **国际化支持**: 完整的i18n解决方案，支持多语言切换

## 📂 项目结构

```
lib/
├── common/                 # 公共模块
│   ├── api/               # API接口层
│   ├── components/        # 公共组件
│   ├── extension/         # 扩展方法
│   ├── i18n/             # 国际化
│   │   ├── locales.dart
│   │   ├── messages.dart
│   │   ├── language_service.dart
│   │   └── index.dart
│   ├── models/           # 数据模型
│   ├── routers/          # 路由管理
│   │   ├── names.dart    # 路由名称
│   │   ├── pages.dart    # 路由配置
│   │   └── observers.dart # 路由观察者
│   ├── services/         # 服务层
│   │   ├── config.dart   # 配置服务
│   │   ├── http.dart     # HTTP服务
│   │   └── storage.dart  # 存储服务
│   ├── style/            # 样式主题
│   ├── utils/            # 工具类
│   ├── values/           # 常量值
│   └── widgets/          # 自定义组件
├── pages/                # 页面模块
│   └── home/             # 首页示例
│       ├── controller.dart
│       ├── view.dart
│       └── index.dart
├── global.dart           # 全局配置
└── main.dart            # 应用入口

scripts/                 # 代码生成脚本
├── generate_page.dart   # 页面生成脚本
├── generate_service.dart # 服务生成脚本
├── scan_routes.dart     # 路由扫描脚本
├── revert.dart         # 操作撤回脚本
├── history_manager.dart # 历史记录管理器
├── i18n_manager.dart   # 翻译管理脚本
├── add_translation.dart # 添加翻译脚本
└── demo.dart           # 演示脚本

templates/               # 代码模板
├── page/               # 页面模板
│   ├── controller.dart.template
│   ├── view.dart.template
│   └── index.dart.template
└── service/            # 服务模板
    ├── service.dart.template
    ├── model.dart.template
    └── api.dart.template
```

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone <your-repo-url>
cd flutter_starter
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 运行项目

```bash
flutter run
```

## 🛠️ 代码生成工具

### 生成新页面

使用页面生成脚本快速创建新页面：

```bash
# 生成基础页面
dart run scripts/generate_page.dart user_profile

# 生成模块化页面
dart run scripts/generate_page.dart user_profile user
```

这将生成：
- `lib/pages/user_profile/controller.dart` - 页面控制器
- `lib/pages/user_profile/view.dart` - 页面视图
- `lib/pages/user_profile/index.dart` - 导出文件

如需撤回，运行 `dart run scripts/revert.dart`

### 生成服务模块

使用服务生成脚本创建完整的服务层：

```bash
dart run scripts/generate_service.dart user_service
```

这将生成：
- `lib/common/services/user_service.dart` - 服务类
- `lib/common/models/usermodel.dart` - 数据模型
- `lib/common/api/userapi.dart` - API接口

如需撤回，运行 `dart run scripts/revert.dart`

### 扫描并更新路由

自动扫描所有页面并更新路由配置：

```bash
dart run scripts/scan_routes.dart
```

这将自动更新：
- `lib/common/routers/names.dart` - 路由名称
- `lib/common/routers/pages.dart` - 路由配置
- `lib/pages/index.dart` - 页面导出

### 撤回操作

如果生成错误，可以撤回最近的操作：

```bash
# 交互式撤回
dart run scripts/revert.dart

# 查看操作历史
dart run scripts/revert.dart --list

# 撤回指定操作
dart run scripts/revert.dart <operation_id>

# 清空历史记录
dart run scripts/revert.dart --clear
```

### 国际化管理

管理多语言翻译：

```bash
# 检查缺失的翻译
dart run scripts/i18n_manager.dart --check

# 添加新翻译
dart run scripts/add_translation.dart "new_key" "中文翻译" "English Translation"

# 查看翻译统计
dart run scripts/i18n_manager.dart --stats

# 验证翻译格式
dart run scripts/i18n_manager.dart --validate

# 导出翻译到JSON
dart run scripts/i18n_manager.dart --export
```

### 查看演示

查看脚手架功能演示：

```bash
dart run scripts/demo.dart
```

## 📝 使用指南

### 页面开发

1. **创建页面**：
   ```bash
   dart run scripts/generate_page.dart my_page
   ```

2. **实现控制器逻辑**：
   ```dart
   class MyPageController extends GetxController {
     // 响应式数据
     final count = 0.obs;
     
     // 业务方法
     void increment() => count++;
     
     @override
     void onInit() {
       super.onInit();
       // 初始化逻辑
     }
   }
   ```

3. **构建页面视图**：
   ```dart
   class MyPagePage extends GetView<MyPageController> {
     Widget _buildView() {
       return Obx(() => Text('Count: ${controller.count}'));
     }
   }
   ```

### 服务开发

1. **创建服务**：
   ```bash
   dart run scripts/generate_service.dart user_service
   ```

2. **完善数据模型**：
   ```dart
   class UserModel {
     final String id;
     final String name;
     final String email;
     
     // 添加自定义字段和方法
   }
   ```

3. **实现API接口**：
   ```dart
   class UserApi {
     // 实现具体的API调用
     Future<Response> login(String email, String password) async {
       return await _httpService.post('/auth/login', data: {
         'email': email,
         'password': password,
       });
     }
   }
   ```

4. **注册服务**：
   ```dart
   // 在global.dart中注册
   Get.put<UserService>(UserService());
   ```

### 路由导航

```dart
// 命名路由导航
Get.toNamed(RouteNames.userProfile);

// 带参数导航
Get.toNamed(RouteNames.userProfile, arguments: {'userId': '123'});

// 替换当前页面
Get.offNamed(RouteNames.login);

// 清空堆栈并导航
Get.offAllNamed(RouteNames.home);
```

### 状态管理

```dart
// 响应式变量
final count = 0.obs;
final user = Rxn<UserModel>();
final isLoading = false.obs;

// 获取响应式数据
Obx(() => Text('${count.value}'));

// 更新数据
count.value++;
user.value = UserModel(name: 'John');
isLoading.toggle();
```

### HTTP请求

```dart
// GET请求
final response = await HttpService.to.get('/api/users');

// POST请求
final response = await HttpService.to.post('/api/users', data: {
  'name': 'John',
  'email': 'john@example.com',
});

// 带查询参数
final response = await HttpService.to.get('/api/users', 
  queryParameters: {'page': 1, 'limit': 20}
);
```

### 本地存储

```dart
// 保存数据
await Storage().setString('token', 'your_token');
await Storage().setBool('isFirstTime', false);

// 读取数据
final token = Storage().getString('token');
final isFirstTime = Storage().getBool('isFirstTime') ?? true;

// 删除数据
await Storage().remove('token');
```

## 🎨 自定义配置

### 自定义代码模板

代码模板位于 `templates/` 目录下，您可以根据需要修改：

- `templates/page/` - 页面模板
- `templates/service/` - 服务模板

模板使用 `{{variableName}}` 语法进行变量替换。

### 修改应用主题

在 `main.dart` 中自定义主题：

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
),
```

### 配置HTTP服务

在 `lib/common/services/http.dart` 中修改基础配置：

```dart
String get baseUrl => 'https://your-api.com';
int get connectTimeout => 15000;
int get receiveTimeout => 15000;
```

### 添加拦截器

```dart
_dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    // 添加认证头
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  },
));
```

## 📚 依赖说明

- **get**: GetX状态管理框架
- **dio**: HTTP客户端
- **shared_preferences**: 本地存储
- **package_info_plus**: 应用信息获取
- **flutter_localizations**: 国际化支持

## 🔧 开发规范

### 命名规范

- **文件名**: 使用下划线分隔 (`user_profile.dart`)
- **类名**: 使用PascalCase (`UserProfile`)
- **变量名**: 使用camelCase (`userName`)
- **常量**: 使用大写下划线 (`API_BASE_URL`)

### 目录规范

- 每个页面独立目录，包含controller、view、index文件
- 公共模块按功能分类放在common目录
- 资源文件放在assets目录
- 脚本文件放在scripts目录

### Git规范

```bash
# 功能开发
git commit -m "feat: 添加用户登录功能"

# 问题修复
git commit -m "fix: 修复登录状态异常"

# 文档更新
git commit -m "docs: 更新README文档"
```

## 🤝 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 提交Pull Request

## 📄 许可证

本项目采用 MIT 许可证。详情请查看 [LICENSE](LICENSE) 文件。

## 🙋‍♂️ 问题反馈

如果你在使用过程中遇到问题，请通过以下方式反馈：

- 提交 [Issue](https://github.com/your-username/flutter_starter/issues)
- 发送邮件到 your-email@example.com

---

⭐ 如果这个项目对你有帮助，请给它一个Star！
