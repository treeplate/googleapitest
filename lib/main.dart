import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart';
import 'package:googleapis/chat/v1.dart' hide TextButton, Card;

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  GoogleSignInAccount? _currentUser;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  HangoutsChatApi? api;
  static const List<String> scopes = [
    HangoutsChatApi.chatSpacesCreateScope,
    HangoutsChatApi.chatSpacesReadonlyScope,
    HangoutsChatApi.chatMessagesCreateScope,
    HangoutsChatApi.chatMessagesReadonlyScope,
  ];
  List<Space>? spaces;
  Space? selectedSpace;
  List<Message>? messages;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _googleSignIn
        .initialize(
          clientId:
              "529808968087-mku5d0qk03l3mv8msq9ap3qb2jk1vs97.apps.googleusercontent.com",
        )
        .then((_) {
          _googleSignIn.authenticationEvents.listen((event) {
            setState(() {
              _currentUser = switch (event) {
                GoogleSignInAuthenticationEventSignIn() => event.user,
                _ => null,
              };
            });
            api = null;
            spaces = null;
            selectedSpace = null;
            messages = null;
            _currentUser!.authorizationClient.authorizeScopes(scopes).then((
              GoogleSignInClientAuthorization? auth,
            ) {
              setState(() {
                api = HangoutsChatApi(auth!.authClient(scopes: scopes));
              });
              api!.spaces.list().then((spaces) {
                setState(() {
                  this.spaces = spaces.spaces;
                });
              });
            });
          });
          // Attempt to authenticate a previously signed in user.
          _googleSignIn.attemptLightweightAuthentication();
        });
  }

  void refresh() {
    api!.spaces.list().then((spaces) {
      setState(() {
        this.spaces = spaces.spaces;
      });
    });
    if (selectedSpace != null) {
      api!.spaces.messages.list(selectedSpace!.name!).then((e) {
        setState(() {
          messages = e.messages;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: Drawer(
          child: _currentUser == null
              ? renderButton()
              : api == null
              ? LoadingScreen('Authenticating...')
              : spaces == null
              ? LoadingScreen('Loading spaces...')
              : Column(
                  children: [
                    OutlinedButton(onPressed: refresh, child: Text('Refresh')),
                    ...spaces!.map(
                      (e) => TextButton(
                        child: Text(
                          e.displayName ?? 'unnamed',
                        ),
                        onPressed: () {
                          setState(() {
                            selectedSpace = e;
                            messages = null;
                          });
                          api!.spaces.messages.list(selectedSpace!.name!).then((
                            e,
                          ) {
                            setState(() {
                              messages = e.messages;
                            });
                          });
                        },
                      ),
                    ),
                  ],
                ),
        ),
        body: Center(
          child: _currentUser == null
              ? renderButton()
              : api == null
              ? LoadingScreen('Authenticating...')
              : spaces == null
              ? LoadingScreen('Loading spaces...')
              : selectedSpace == null
              ? Text('No selected space. Open the hamburger menu.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${selectedSpace!.displayName}',
                      style: TextStyle(fontSize: 50),
                    ),
                    messages == null
                        ? LoadingScreen('loading messages')
                        : Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ...messages!.map((e) => Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SelectableText(e.sender!.displayName ?? e.sender!.name!),
                                          SelectableText(e.text!),
                                        ],
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: textEditingController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              api!.spaces.messages.create(
                                Message(text: textEditingController.text),
                                selectedSpace!.name!,
                              ).then((_) => refresh());
                            },
                            icon: Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MainApp());
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen(this.reason, {super.key});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [CircularProgressIndicator(), Text(reason)],
    );
  }
}