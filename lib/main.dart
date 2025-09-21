import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart';
import 'package:googleapis/chat/v1.dart' as chat;

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'datastructure.dart';
import 'retriever.dart';
import 'package:web/web.dart' hide Text;

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  GoogleSignInAccount? _currentUser;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  chat.HangoutsChatApi? api;
  static const List<String> scopes = [
    chat.HangoutsChatApi.chatSpacesCreateScope,
    chat.HangoutsChatApi.chatSpacesReadonlyScope,
    chat.HangoutsChatApi.chatMessagesCreateScope,
    chat.HangoutsChatApi.chatMessagesReadonlyScope,
    chat.HangoutsChatApi.chatMembershipsReadonlyScope,
  ];
  List<Space>? spaces;
  Space? selectedSpace;
  TextEditingController textEditingController = TextEditingController();
  bool loggedIn = false;

  void login(String clientID) {
    loggedIn = true;
    _googleSignIn.initialize(clientId: clientID).then((_) {
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
        _currentUser!.authorizationClient.authorizeScopes(scopes).then((
          GoogleSignInClientAuthorization? auth,
        ) {
          setState(() {
            api = chat.HangoutsChatApi(auth!.authClient(scopes: scopes));
          });
          refresh();
        });
      });
      // Attempt to authenticate a previously signed in user.
      _googleSignIn.attemptLightweightAuthentication();
    });
  }

  void refresh() {
    getSpaces(api!).then((spaces) {
      setState(() {
        this.spaces = spaces;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: spaces == null
            ? null
            : Drawer(
                child: Column(
                  children: [
                    OutlinedButton(onPressed: refresh, child: Text('Refresh')),
                    ...spaces!.map(
                      (e) => TextButton(
                        child: Text(e.displayName ?? 'unnamed'),
                        onPressed: () {
                          setState(() {
                            selectedSpace = e;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
        body: Center(
          child: !loggedIn
              ? TextField(
                  onSubmitted: (text) => setState(() {
                    window.document.getElementById('placeholderclientid')!.setAttribute('content', text);
                    login(text);
                  }),
                )
              : _currentUser == null
              ? renderButton()
              : api == null
              ? LoadingScreen('Authenticating...')
              : spaces == null
              ? TextButton(
                  onPressed: () {
                    refresh();
                  },
                  child: LoadingScreen('Loading spaces...'),
                )
              : selectedSpace == null
              ? Text('No selected space. Open the hamburger menu.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${selectedSpace!.displayName}',
                      style: TextStyle(fontSize: 50),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...selectedSpace!.messages.map(
                              (e) => Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Wrap(
                                    children: [
                                      SelectableText(e.senderIdentifier),
                                      SelectableText(e.formattedText),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
                              api!.spaces.messages
                                  .create(
                                    chat.Message(
                                      text: textEditingController.text,
                                    ),
                                    selectedSpace!.identifier,
                                  )
                                  .then((_) => refresh());
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
