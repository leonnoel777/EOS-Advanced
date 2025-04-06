import 'package:flutter/material.dart';
import 'package:house_of_tomorrow/src/view/base_view_model.dart';
import 'package:house_of_tomorrow/theme/component/circular_indicator.dart';
import 'package:provider/provider.dart';

//제네릭 클래스는 다양한 데이터 타입에 대해 동일한 코드를 재사용할 수 있게 해주는 프로그래밍 기법입니다.

//동일한 로직을 다양한 타입에 적용할 수 있어 중복 코드를 줄입니다.
class Box<T> {
  T value;
  Box(this.value);

  T getValue() {
    return value;
  }
}

// 사용 예
var intBox = Box<int>(123);
var stringBox = Box<String>("안녕하세요");

//여러 종류의 뷰모델을 받을 수 있지만, 모두 BaseViewModel을 상속해야 합니다.

class BaseView<T extends BaseViewModel> extends StatelessWidget {
  const BaseView({
    super.key,
    required this.viewModel,
    required this.builder,
  });

  final T viewModel;
  final Widget Function(BuildContext context, T viewModel) builder;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => viewModel,
      child: Consumer<T>(
        //builder 함수에 정확한 뷰모델 타입이 전달됩니다.
        builder: (context, viewModel, child) {
          return CircularIndicator(
            isBusy: viewModel.isBusy,
            child: builder(context, viewModel),
          );
        },
      ),
    );
  }
}
