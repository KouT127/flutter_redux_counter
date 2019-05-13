import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class IntIncrementAction {}

class DoubleIncrementAction {}

@immutable
class AppState {
  final int intCount;
  final double doubleCount;

  const AppState({
    this.intCount = 0,
    this.doubleCount = 0.0,
  });

  AppState copyWith({
    int intCount,
    double doubleCount,
  }) {
    return AppState(
      intCount: intCount ?? this.intCount,
      doubleCount: doubleCount ?? this.doubleCount,
    );
  }
}

final counterReducer = combineReducers<AppState>([
  TypedReducer<AppState, IntIncrementAction>(intIncrement),
  TypedReducer<AppState, DoubleIncrementAction>(doubleIncrement),
]);

AppState intIncrement(AppState state, IntIncrementAction action) {
  return state.copyWith(intCount: state.intCount + 1);
}

AppState doubleIncrement(AppState state, DoubleIncrementAction action) {
  return state.copyWith(doubleCount: state.doubleCount + 1.0);
}

void main() {
  final store = Store<AppState>(
    counterReducer,
    initialState: AppState(),
    middleware: [],
  );

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

class TapViewModel {
  final VoidCallback onIntIncrementTap;
  final VoidCallback onDoubleIncrement;

  TapViewModel({
    this.onIntIncrementTap,
    this.onDoubleIncrement,
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
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You have pushed the button this many times:',
              ),
              Column(
                children: <Widget>[
                  IntText(),
                  DoubleText(),
                ],
              ),
              StoreConnector<AppState, TapViewModel>(
                converter: (store) => TapViewModel(
                    onIntIncrementTap: () =>
                        store.dispatch(IntIncrementAction()),
                    onDoubleIncrement: () =>
                        store.dispatch(DoubleIncrementAction())),
                ignoreChange: (_) => true,
                builder: (context, vm) {
                  return Column(
                    children: <Widget>[
                      RaisedButton(
                        onPressed: vm.onIntIncrementTap,
                        child: const Text('increment'),
                      ),
                      RaisedButton(
                        onPressed: vm.onDoubleIncrement,
                        child: const Text('increment'),
                      ),
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class IntViewModel extends Equatable {
  final String intCount;

  IntViewModel({
    AppState state,
  })  : intCount = state.intCount.toString(),
        super([state.intCount]);
}

class IntText extends StatefulWidget {
  @override
  _IntTextState createState() => _IntTextState();
}

class _IntTextState extends State<IntText> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, IntViewModel>(
      distinct: true,
      converter: (store) => IntViewModel(state: store.state),
      builder: (context, viewModel) {
        print('int rebuild');
        return Text(
          viewModel.intCount,
          style: Theme.of(context).textTheme.display1,
        );
      },
    );
  }
}

class DoubleViewModel {
  final String doubleCount;

  DoubleViewModel({
    AppState state,
  }) : this.doubleCount = state.doubleCount.toString();

  @override
  int get hashCode => doubleCount.hashCode;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        other is DoubleViewModel &&
            runtimeType == other.runtimeType &&
            doubleCount == other.doubleCount;
  }
}

class DoubleText extends StatefulWidget {
  @override
  _DoubleTextState createState() => _DoubleTextState();
}

class _DoubleTextState extends State<DoubleText> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DoubleViewModel>(
      distinct: true,
      converter: (store) => DoubleViewModel(state: store.state),
      builder: (context, viewModel) {
        print('double rebuild');
        return Text(
          viewModel.doubleCount,
          style: Theme.of(context).textTheme.display1,
        );
      },
    );
  }
}
