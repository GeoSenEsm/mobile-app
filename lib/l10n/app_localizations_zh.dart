// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get login => '登录';

  @override
  String get weNeedInformation => '我们需要您的一些信息';

  @override
  String get letsStart => '这里开始';

  @override
  String get lifeSatisfaction => '生活满意度';

  @override
  String get stressLevel => '压力水平';

  @override
  String get qualityOfSleep => '睡眠质量';

  @override
  String get next => '下一步';

  @override
  String get healthCondition => '健康状况';

  @override
  String get medicationUse => '用药情况';

  @override
  String get gender => '性别';

  @override
  String get ageCategory => '年龄类别';

  @override
  String get employment => '就业状态';

  @override
  String get education => '教育程度';

  @override
  String get greeneryArea => '绿化区域';

  @override
  String get initializeSurveyQuestion => '您愿意开始调查吗?';

  @override
  String get start => '开始';

  @override
  String get endSurveyQuestion => '您希望结束调查吗？提交后您将无法再编辑您的答案';

  @override
  String get finish => '完成';

  @override
  String get error => '错误';

  @override
  String get nextSurveyTime => '下次计划调查的剩余时间';

  @override
  String get surveyDetails => '调查详情';

  @override
  String get loadingSurveyErrorTryAgainLater => '未能加载调查，请稍后再试';

  @override
  String get loadingSurveyError => '未能加载所选调查';

  @override
  String get answerSubmitError => '未能提交答案';

  @override
  String get mainPageTransitionError => '回答已成功发送到服务器，但在返回主页时发生错误。尝试重新启动应用程序.';

  @override
  String get selectOneOption => '请选择一个选项';

  @override
  String get noInternetTryAgain => '您当前没有互联网连接，请稍后再试。';

  @override
  String get woman => '女性';

  @override
  String get man => '男性';

  @override
  String get invalidCredentials => '无效凭证';

  @override
  String get passwordNotEmpty => '密码不能为空';

  @override
  String passwordTooLong(int max) {
    return '密码长度不得超过 $max 个字符';
  }

  @override
  String get usernameNotEmpty => '用户名不能为空';

  @override
  String usernameTooLong(int max) {
    return '用户名长度不得超过 $max 个字符';
  }

  @override
  String get hours => '小时';

  @override
  String get minutes => '分钟';

  @override
  String get valueNotEmpty => '值不能为空';

  @override
  String get errorRetry => '错误，请重试';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get usedSensor => '温度传感器类型';

  @override
  String get save => '保存';

  @override
  String get chooseATemperatureSensorYouReceived => '选择您已接收的温度传感器';

  @override
  String get noSensor => '无传感器';

  @override
  String get xiaomiSensor => '小米传感器';

  @override
  String get settings => '设置';

  @override
  String get editSensor => '编辑传感器';

  @override
  String get appSettings => '应用设置';

  @override
  String get surveyStartBody => '您可以现在开始调查。准备好了吗？';

  @override
  String get surveyFinishBody => '调查即将结束。我们来做吧！';

  @override
  String get pleaseEnterNumber => '请输入数字';

  @override
  String get enterNumber => '输入数字';

  @override
  String get pleaseEnterValidNumber => '请输入有效数字';

  @override
  String get pleaseEnterLeastZeroNumber => '请输入至少为0的数字';

  @override
  String get pleaseEnterNumberLessThan1000 => '请输入小于1000的数字';

  @override
  String get pleaseEnterAnyText => '请输入您的答案';

  @override
  String get pleaseEnterShorterText => '请输入少于1000个字符的答案';

  @override
  String get selectAtLeastOneOption => '请至少选择一个选项';

  @override
  String get apiUrl => 'API地址';

  @override
  String get apiUrlEmptyErrorMessage => 'API url 不能为空';

  @override
  String get apiUrlInvalidFormatErrorMessage => '格式无效';

  @override
  String get logout => '注销登录';

  @override
  String get logountConfirmationQuestion => '您确定要注销吗？尚未上传到服务器的所有数据都将丢失';

  @override
  String get couldNotLogout => '未能注销，稍后再试';

  @override
  String get credentialsExpired => '您的密码已过期，请重新输入密码.';

  @override
  String get profile => '个人资料';

  @override
  String get couldNotReachTheServer => '请求发送失败，请稍后再试';

  @override
  String get somethingWentWrong => '出了点问题，请稍后再试';

  @override
  String get locationPermissionDenied => '位置权限被拒绝';

  @override
  String get locationPermissionDeniedMessage =>
      '持续的位置权限对于填写调查是必需的。请在设备设置中启用它。\n请选择“始终允许';

  @override
  String get locationBackgroundPermissionDenied => '缺少后台定位权限';

  @override
  String get locationBackgroundPermissionDeniedMessage =>
      '建议启用后台定位权限。请点击“打开设置”，然后选择“始终允许”。';

  @override
  String get openSettings => '打开设置';

  @override
  String get close => '关闭';

  @override
  String get notifications => '通知';

  @override
  String get privacy => '隐私';

  @override
  String get privacySettings => '隐私设置';

  @override
  String get allowTrackLocation => '允许位置跟踪';

  @override
  String get timeFrom => '开始时间';

  @override
  String get timeTo => '结束时间';

  @override
  String get notifyMeAboutSurveys => '通知我有关调查';

  @override
  String get openPrivacyPolicy => '打开隐私政策';

  @override
  String get changePassword => '修改密码';

  @override
  String get currentPassword => '当前密码';

  @override
  String get newPassword => '新密码';

  @override
  String get retypePassword => '重复输入密码';

  @override
  String get passwordChangedSuccessfully => '您的密码已修改成功';

  @override
  String get ok => '确定';

  @override
  String get currentPasswordMustNotBeEmpty => '当前密码不能为空';

  @override
  String get minNewPasswordLenError => '最小长度为8个字符';

  @override
  String get retypePasswordMustBeEqualToNewPassword => '输入的值必须与新密码相同';

  @override
  String get iAcceptPrivacyPolicy => '我接受隐私条款';

  @override
  String get scrollToTheVeryBottom => '滚动到最底部';

  @override
  String get loadingImageFailed => '未能加载图片';

  @override
  String get multiplePermissionsDenied => '缺少权限';

  @override
  String get multiplePermissionsDeniedMessage => '请在设备设置中启用被拒绝的权限，方法是前往设置中的权限';

  @override
  String get surveyFinishTitle => '完成调查';

  @override
  String get surveyStartTitle => '新调查';

  @override
  String get sensorDataHistory => '历史读数';

  @override
  String get saveReading => '保存读数';

  @override
  String get scanning => '正在扫描';

  @override
  String get bluetoothTurnedOff => '蓝牙已关闭';

  @override
  String get sensorNotFound => '无法检测到传感器';

  @override
  String get sensorNotSpecified => '未指定传感器';

  @override
  String get sensorData => '传感器数据';

  @override
  String get calendar => '日历';

  @override
  String get day => '天';

  @override
  String get week => '周';

  @override
  String get surveyName => '问卷名称';

  @override
  String get end => '结束';

  @override
  String get sensorHistory => '传感器历史';

  @override
  String get dateFrom => '开始日期';

  @override
  String get dateTo => '结束日期';

  @override
  String get clearFilters => '清除筛选';

  @override
  String get apply => '应用';

  @override
  String get thisWeek => '本周';

  @override
  String get from => '从';

  @override
  String get to => '到';

  @override
  String get date => '日期';

  @override
  String get temperature => '温度';

  @override
  String get humidity => '湿度';

  @override
  String get sentToServer => '已发送到服务器';

  @override
  String get menu => '菜单';

  @override
  String get map => '地图';

  @override
  String get today => '今天';

  @override
  String get latidude => '纬度';

  @override
  String get longitude => '经度';

  @override
  String get time => '时间';

  @override
  String get theLocationDataHasBeenSubmitedToServer => '该位置已提交到服务器';

  @override
  String get theLocationDataHasNotBeenSubmitedToServer => '该位置尚未提交到服务器';

  @override
  String get surveyHasBeenComplitedInThisLocation => '该位置已完成问卷';

  @override
  String get enterResponse => '输入回答';

  @override
  String get kestrelDrop2 => 'Kestrel Drop 2 传感器';

  @override
  String get sensorId => '传感器ID';

  @override
  String get serverNotResponding => '服务器无响应。请确保提供了正确的API地址，如无误，请稍后重试。';

  @override
  String get bluetoothRequired => '请打开蓝牙以完成问卷。';

  @override
  String get bluetooth => '蓝牙';

  @override
  String get surveyFinished => '问卷已结束，无法再完成。';

  @override
  String get sensorMac => '传感器MAC地址';

  @override
  String get sensorIdServerNotFound => '服务器上未找到传感器ID';

  @override
  String get noInternetConnection => '无网络连接';

  @override
  String get betterExperienceTurnOnInternet => '为了更好的体验，请开启网络连接';

  @override
  String get loadingMacFailed => '无法加载MAC地址';

  @override
  String get sensorNotFoundDialogTitle => '未找到传感器';

  @override
  String get sensorNotFoundDialogContent =>
      '未找到温度传感器。问卷将不包含温度数据。请确保您携带了传感器并且电池有电。';

  @override
  String get thanksForCompletingTheSurvey => '感谢您完成问卷。';

  @override
  String nextSurveyWillAppearIn(String time) {
    return '下一个问卷将在$time后出现。';
  }

  @override
  String get nextSurveyIsReadyToComplete => '下一个问卷已准备好。';

  @override
  String loginFailedServerRespondedWithStatusCode(int code) {
    return '登录失败。服务器返回状态码$code。请稍后再试。';
  }

  @override
  String get weWereUnableToDetermineTheServerAvailibility =>
      '由于某些法律限制，我们需要确认你是否可以使用提供的 API 地址。但目前我们无法完成验证。请稍后再试';

  @override
  String get theServerYouProvidedIsNotAllowedInYourLocation =>
      '你提供的服务器在你所在的位置不被允许使用';

  @override
  String get help => '帮助';

  @override
  String get contact => '联系';

  @override
  String get errorLoadingContacts => '加载联系人时发生错误。请确保您已连接到互联网，然后稍后重试。';

  @override
  String get refreshContacts => '刷新';

  @override
  String get noContacts => '研究管理员尚未定义任何联系电话号码。';

  @override
  String get call => '拨打';

  @override
  String get couldNotMakeCall => '拨打电话失败。';

  @override
  String get warning => '警告';

  @override
  String get noSensorSelected => '未选择温度传感器。完成问卷后，传感器数据将不会被保存。建议前往设置选择传感器。';

  @override
  String get continueWithoutSensor => '继续而不使用传感器';
}
