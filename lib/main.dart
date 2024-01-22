import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: GoRouter(
            errorBuilder: (context, state) => const ErrorPage(),
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTile(
                            title: const Text('Cool Swatch'),
                            onTap: () => context.go('/pallet/1'),
                          ),
                          ListTile(
                            title: const Text('Warm Swatch'),
                            onTap: () => context.go('/pallet/2'),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              ShellRoute(
                  builder: (context, state, child) {
                    return Scaffold(
                      appBar: AppBar(
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            final String? colorId = state
                                .pathParameters['colorId'];
                            if (colorId == null) {
                              context.go('/');
                            } else {
                              final int palletId = int.parse(
                                  state.pathParameters['palletId']!);
                              context.go('/pallet/$palletId');
                            }
                          },
                        ),
                        title: const Text('Routing With colors'),
                      ),
                      body: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              if (state.pathParameters['colorId'] == null) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: child,
                                    ),
                                    const Expanded(
                                      child: Center(
                                        child: Text('Select a color'),
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                final int palletId = int.parse(state
                                    .pathParameters['palletId']!
                                );
                                final List<String>? colors = generateColorList(palletId);
                                if(colors != null){
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ColorListWidget(
                                          colors: colors,
                                          palletId: palletId,
                                        ),
                                      ),
                                      Expanded(
                                          child: child
                                      )
                                    ],
                                  );
                                }
                                return const ErrorPage();
                              }
                            }
                            return child;
                          }),
                    );
                  },
                  routes: [
                    GoRoute(
                        path: '/pallet/:palletId',
                        builder: (context, state) {
                          final int palletId = int.parse(
                              state.pathParameters['palletId']!);
                          final List<String>? colors = generateColorList(palletId);
                          if(colors != null){
                            return ColorListWidget(
                                colors: colors,
                                palletId: palletId
                            );
                          }else{
                            return const ErrorPage();
                          }
                        },
                        routes: [
                          GoRoute(
                            path: 'color/:colorId',
                            builder: (context, state) {
                              final String colorId = state
                                  .pathParameters['colorId']!;
                              final Color color = getColorFromString(colorId);
                              return Container(color: color);
                            },
                          )
                        ]
                    ),
                  ]
              )
            ])
    );
  }

  List<String>? generateColorList(int palletId) {
    if (palletId == 1) {
      const List<String> colors = [
        'green',
        'blue',
        'purple'
      ];
      return colors;
    }
    else if (palletId == 2) {
      const List<String> colors = [
        'red',
        'yellow',
        'orange'
      ];
      return colors;
    }
    return null;
  }
}

class ColorListWidget extends StatelessWidget {
  const ColorListWidget({
    super.key,
    required this.colors,
    required this.palletId,
  });

  final List<String> colors;
  final int palletId;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final String colorString = colors[index];
        return ListTile(
          title: Text(colorString),
          tileColor: getColorFromString(colorString),
          shape: const RoundedRectangleBorder(),
          onTap: (){
            context.go('/pallet/$palletId/color/$colorString');
          },
        );
      },
    );
  }
}

Color getColorFromString(String color){
  switch(color){
    case 'red':
      return Colors.red;
    case 'orange':
      return Colors.orange;
    case 'yellow':
      return Colors.yellow;
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'purple':
      return Colors.purple;
    default:
      return Colors.black;
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Unable to find route'),
            TextButton(
                onPressed: ()=> context.go('/'),
                child: const Text('Home')
            )
          ],
        ),
      ),
    );
  }
}