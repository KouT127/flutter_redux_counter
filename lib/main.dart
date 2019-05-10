import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class IncrementAction {}

class NestIncrementAction {}

void delayIncrement(Store<AppState> store, action, NextDispatcher next) {
  if (action is IncrementAction) {
    Future.delayed(Duration(seconds: 1), () {
      next(NestIncrementAction());
    });
  }
  next(action);
}

class AppState {
  final int count;
  final int nestCount;

  AppState({
    this.count = 0,
    this.nestCount = 0,
  });

  AppState copyWith({
    int count,
    int nestCount,
  }) {
    return AppState(
      count: count ?? this.count,
      nestCount: nestCount ?? this.nestCount,
    );
  }
}

final counterReducer = combineReducers<AppState>([
  TypedReducer<AppState, IncrementAction>(increment),
  TypedReducer<AppState, NestIncrementAction>(nestIncrement),
]);

AppState increment(AppState state, IncrementAction action) {
  return state.copyWith(count: state.count + 1);
}

AppState nestIncrement(AppState state, NestIncrementAction action) {
  return state.copyWith(nestCount: state.nestCount + 1);
}

void main() {
  final store =
      Store<AppState>(counterReducer, initialState: AppState(), middleware: [
    delayIncrement,
  ]);

  runApp(MyApp(
    title: 'Flutter Redux Demo',
    store: store,
  ));
}

class MyApp extends StatelessWidget {
  final String title;
  final Store store;

  MyApp({
    this.title,
    this.store,
  });

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: title,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MainScreen(
          title: title,
        ),
      ),
    );
  }
}

class ViewModel {
  final int count;

  ViewModel({
    this.count,
  });

  @override
  int get hashCode => count.hashCode;

  @override
  bool operator ==(dynamic other) {
    return identical(this.hashCode, other.hashCode) &&
        other is ViewModel &&
        runtimeType == other.runtimeType;
  }
}

class TapViewModel {
  final VoidCallback onIncrementTap;
  final VoidCallback onNestIncrementTap;

  TapViewModel({
    this.onIncrementTap,
    this.onNestIncrementTap,
  });
}

class MainScreen extends StatelessWidget {
  final String title;

  MainScreen({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
            ),
            StoreConnector<AppState, ViewModel>(
              distinct: true,
              converter: (store) => ViewModel(
                    count: store.state.count,
                  ),
              builder: (context, vm) {
                print('rebuild');
                return Column(
                  children: <Widget>[
                    Text(
                      vm.count.toString(),
                      style: Theme.of(context).textTheme.display1,
                    ),
                    NestText()
                  ],
                );
              },
            ),
            Column(
              children: <Widget>[
                StoreConnector<AppState, TapViewModel>(
                  converter: (store) => TapViewModel(
                      onIncrementTap: () => store.dispatch(IncrementAction()),
                      onNestIncrementTap: () =>
                          store.dispatch(NestIncrementAction())),
                  ignoreChange: (_) => true,
                  builder: (context, vm) {
                    return Column(
                      children: <Widget>[
                        RaisedButton(
                          onPressed: vm.onIncrementTap,
                          child: const Text('increment'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class NestViewModel {
  final String nestCount;

  NestViewModel({
    AppState state,
  }) : this.nestCount = state.nestCount.toString();

  @override
  int get hashCode => nestCount.hashCode;

  @override
  bool operator ==(dynamic other) {
    return identical(this.hashCode, other.hashCode) &&
        other is NestViewModel &&
        runtimeType == other.runtimeType;
  }
}

class NestText extends StatefulWidget {
  @override
  _NestTextState createState() => _NestTextState();
}

class _NestTextState extends State<NestText> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, NestViewModel>(
      distinct: true,
      converter: (store) => NestViewModel(state: store.state),
      builder: (context, nestViewModel) {
        print('nest rebuild');
        return Text(
          nestViewModel.nestCount,
          style: Theme.of(context).textTheme.display1,
        );
      },
    );
  }
}
