import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/getwidget.dart';
import 'package:survey_frontend/presentation/tab_views/archived_surveys_tab_view.dart';
import 'package:survey_frontend/presentation/tab_views/pendning_surveys_tab_view.dart';
import 'package:survey_frontend/presentation/tab_views/respondent_data_tab_view.dart';
import 'package:survey_frontend/presentation/tab_views/survey_tab.dart';

class HomeScreen extends StatefulWidget{
  
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomeStreenState();
  }
}

class _HomeStreenState extends State<HomeScreen> with TickerProviderStateMixin{
  late TabController _tabController;
  
  _HomeStreenState();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(title: const Text("Home")),
      body: GFTabBarView(
        controller: _tabController,
        children: const [
          RespondentDataTabView(),
          PendingSurveysTabView(),
          ArchivedSurveysTabView()
        ]
      ),
      bottomNavigationBar: GFTabBar(
        controller: _tabController,
        length: 3,
        tabBarColor: Theme.of(context).primaryColor,
        labelColor: Theme.of(context).secondaryHeaderColor,
        unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
        indicatorColor: Theme.of(context).indicatorColor,
        tabs: const [
          SurveyTab(
            iconData: FontAwesomeIcons.user,
            label: "Respondent data"
          ),
          SurveyTab(
            iconData: FontAwesomeIcons.clipboardList,
            label: "Pending surveys"
          ),
          SurveyTab(
            iconData: FontAwesomeIcons.boxArchive,
            label: "Archive"
          ),
        ],
      )
    );
  }
}