import 'package:flutter/widgets.dart';
import 'sim_bloc.dart';

class SimBlocProvider extends InheritedWidget {
  SimBlocProvider({
    this.simBloc,
    @required Widget child
  }) : assert(child != null),
       super(child: child);

  final SimBloc simBloc;

  static SimBloc of(BuildContext context) {
    final provider = context.inheritFromWidgetOfExactType(SimBlocProvider);
    if (provider != null) {
      return (provider as SimBlocProvider).simBloc;
    }

    return null;
  }

  @override
  bool updateShouldNotify(SimBlocProvider old) {
    return simBloc != old.simBloc;
  }
}
