import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MasterEstimateApp());
}

class MasterEstimateApp extends StatelessWidget {
  const MasterEstimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WIN-FAC 통합 견적 산출 프로그램',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFECEFF1),
      ),
      home: const EstimateScreen(),
    );
  }
}

class EstimateScreen extends StatefulWidget {
  const EstimateScreen({super.key});

  @override
  State<EstimateScreen> createState() => _EstimateScreenState();
}

class _EstimateScreenState extends State<EstimateScreen> {
  // ─── [데이터 세팅 및 옵션 맵 정의] ───
  final List<String> _masterModels = ['M500', 'M300', 'Z350', 'IBF225'];

  final Map<String, List<String>> _subModelsMap = {
    'M500': ['WHITE', 'ASA', 'AL CAP'],
    'M300': ['TT'],
    'Z350': ['내:S/S 외:FLS', '내:L/S 외:FS', '내:S/S 외:FS', '내:L/S 외:LFS'],
    'IBF225': ['IBF'],
  };

  final Map<String, List<String>> _typesMap = {
    'M500': ['1S1F', '2S1F', '2S2F'],
    'M300': ['1V1F', '1V1F(V)', '1V2F', '1V2F(V)', '1V3F', '2V1F', '2V4F'],
    'Z350': ['1S1F', '2S1F'],
    'IBF225': ['1V1F', '2V1F'],
  };

  // ─── [현재 선택된 상태 변수들] ───
  String _selectedMaster = 'M500';
  String _selectedSub = 'WHITE';
  String _selectedType = '1S1F';

  // ─── [구간 2: 사이즈 및 수량 입력 변수들] ───
  double _inputW = 0.0;
  double _inputH = 0.0;
  double _inputW1 = 0.0;
  double _inputH1 = 0.0;
  double _inputW2 = 0.0;
  double _inputH2 = 0.0;
  double _inputH3 = 0.0;
  int _quantity = 1;

  // ─── [구간 3: 가공비 변수 (% 정수형)] ───
  int _processPercentage = 0;

  // ─── [구간 4: 모델별 제작 조건 독립 변수들] ───
  // M500 조건
  String _m500InnerColor = 'White';
  String _m500WindowType = 'SI Type(일반)';
  String _m500GlassRailing = '미적용';
  String _m500Welding = 'TWL';

  // M300 조건
  String _m300Hardware = 'TT';
  String _m300Finishing = 'AL CAP';

  // Z350 조건
  String _z350InnerColor = 'White';
  String _z350InnerFace = 'White';
  String _z350OuterFace = 'ASA';
  String _z350ScreenHandle = '미적용';
  String _z350GlassRailing = '미적용';
  String _z350Welding = 'TWL';

  // IBF225 조건
  String _ibfHardware = 'TT';

  // 최종 산출 금액
  int _finalResult = 0;

  @override
  void initState() {
    super.initState();
    _resetToDefault(_selectedMaster);
  }

  // 모델 종류나 구성 등이 바뀌면 기존 계산 결과를 0원으로 리셋
  void _resetToDefault(String master) {
    setState(() {
      _selectedMaster = master;
      _selectedSub = _subModelsMap[master]!.first;
      _selectedType = _typesMap[master]!.first;

      _inputW = 0.0;
      _inputH = 0.0;
      _inputW1 = 0.0;
      _inputH1 = 0.0;
      _inputW2 = 0.0;
      _inputH2 = 0.0;
      _inputH3 = 0.0;
      _quantity = 1;
      _finalResult = 0; // ✅ 새로운 선택 시 금액 초기화
    });
  }

  // ─── [구간 5: 견적 산출 버튼을 누를 때만 실행되는 수식] ───
  void _calculate() {
    double baseCalc = 0.0;

    if (_selectedMaster == 'M500') {
      double rawMaterial =
          (_inputW * _inputH * 0.02) + (_inputW1 * _inputH1 * 0.01);
      baseCalc = rawMaterial + (rawMaterial * (_processPercentage / 100));
      if (_m500InnerColor == '랩핑') baseCalc += 30000;
      if (_m500GlassRailing == '적용') baseCalc += 50000;
    } else if (_selectedMaster == 'M300') {
      double rawMaterial = (_inputW * _inputH * 0.025);
      baseCalc =
          (rawMaterial + (rawMaterial * (_processPercentage / 100))) *
          _quantity;
      if (_m300Hardware == 'Turn Only') baseCalc += 15000;
    } else if (_selectedMaster == 'Z350') {
      double rawMaterial = (_inputW * _inputH * 0.03);
      baseCalc = rawMaterial + (rawMaterial * (_processPercentage / 100));
      if (_z350OuterFace == 'AL CAP') baseCalc += 45000;
    } else if (_selectedMaster == 'IBF225') {
      double rawMaterial = (_inputW * _inputH * 0.018);
      baseCalc =
          (rawMaterial + (rawMaterial * (_processPercentage / 100))) *
          _quantity;
    }

    setState(() {
      _finalResult = baseCalc.round();
    });
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'WIN-FAC 통합 견적 산출 프로그램',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 12.0,
            right: 12.0,
            top: 12.0,
            bottom: 100.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // [최상위 상용구] 상위 모델 선택 콤보박스
              Card(
                color: Colors.amber.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.amber, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedMaster,
                    decoration: const InputDecoration(
                      labelText: '제품 선택',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    items: _masterModels
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(
                              m,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      _unfocus();
                      if (val != null) _resetToDefault(val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ─── [구간 1] 하위 모델명 및 구성 선택 ───
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSub,
                          decoration: const InputDecoration(
                            labelText: '모델명',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          items: _subModelsMap[_selectedMaster]!
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(
                                    m,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            _unfocus();
                            setState(() {
                              _selectedSub = val!;
                              _finalResult = 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: const InputDecoration(
                            labelText: '구성',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                          items: _typesMap[_selectedMaster]!
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    t,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            _unfocus();
                            setState(() {
                              _selectedType = val!;
                              _finalResult = 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ─── [구간 2] 동적 사이즈 및 수량 입력창 ───
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '사이즈 입력',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _unfocus(),
                              decoration: const InputDecoration(
                                labelText: 'W (폭)',
                                border: OutlineInputBorder(),
                                suffixText: 'mm',
                              ),
                              onChanged: (val) {
                                _inputW = double.tryParse(val) ?? 0;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _unfocus(),
                              decoration: const InputDecoration(
                                labelText: 'H (높이)',
                                border: OutlineInputBorder(),
                                suffixText: 'mm',
                              ),
                              onChanged: (val) {
                                _inputH = double.tryParse(val) ?? 0;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _unfocus(),
                              decoration: const InputDecoration(
                                labelText: 'W1',
                                border: OutlineInputBorder(),
                                suffixText: 'mm',
                              ),
                              onChanged: (val) {
                                _inputW1 = double.tryParse(val) ?? 0;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _unfocus(),
                              decoration: const InputDecoration(
                                labelText: 'H1',
                                border: OutlineInputBorder(),
                                suffixText: 'mm',
                              ),
                              onChanged: (val) {
                                _inputH1 = double.tryParse(val) ?? 0;
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_selectedMaster == 'M300' ||
                          _selectedMaster == 'IBF225') ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _unfocus(),
                                decoration: const InputDecoration(
                                  labelText: 'W2',
                                  border: OutlineInputBorder(),
                                  suffixText: 'mm',
                                ),
                                onChanged: (val) {
                                  _inputW2 = double.tryParse(val) ?? 0;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _unfocus(),
                                decoration: const InputDecoration(
                                  labelText: 'H2',
                                  border: OutlineInputBorder(),
                                  suffixText: 'mm',
                                ),
                                onChanged: (val) {
                                  _inputH2 = double.tryParse(val) ?? 0;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_selectedMaster == 'M300' &&
                          _selectedType == '1V2F(V)') ...[
                        const SizedBox(height: 10),
                        TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _unfocus(),
                          decoration: const InputDecoration(
                            labelText: 'H3',
                            border: OutlineInputBorder(),
                            suffixText: 'mm',
                          ),
                          onChanged: (val) {
                            _inputH3 = double.tryParse(val) ?? 0;
                          },
                        ),
                      ],
                      if (_selectedMaster == 'M300' ||
                          _selectedMaster == 'IBF225') ...[
                        const SizedBox(height: 10),
                        TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _unfocus(),
                          decoration: const InputDecoration(
                            labelText: '수량 입력',
                            border: OutlineInputBorder(),
                            suffixText: '개',
                            hintText: '1',
                          ),
                          onChanged: (val) {
                            _quantity = int.tryParse(val) ?? 1;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ─── [구간 3] 가공비 설정 (단위: %, 우측정렬) ───
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '가공비 설정',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(height: 16),
                      TextField(
                        style: const TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _unfocus(),
                        decoration: const InputDecoration(
                          labelText: '가공비 입력',
                          border: OutlineInputBorder(),
                          suffixText: ' %',
                          hintText: '0',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (val) {
                          _processPercentage = int.tryParse(val) ?? 0;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ─── [구간 4] 상위 모델별 실시간 렌더링 제작 조건 단일선택 영역 ───
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_selectedMaster($_selectedSub) $_selectedType 제작 조건 세부 설정',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(height: 20),

                      if (_selectedMaster == 'M500') ...[
                        _buildRadioGroup(
                          '내부 색상',
                          ['White', '랩핑'],
                          _m500InnerColor,
                          (val) => setState(() => _m500InnerColor = val),
                        ),
                        const Divider(),
                        _buildRadioGroup(
                          '창짝 선택 (SI)',
                          ['SI Type(일반)', 'SI Type(고풍압)'],
                          _m500WindowType,
                          (val) => setState(() => _m500WindowType = val),
                          secondaryOptions: ['KZ Type(일반)', 'KZ Type(고풍압)'],
                        ),
                        const Divider(),
                        _buildRadioGroup(
                          '유리난간대',
                          ['미적용', '적용'],
                          _m500GlassRailing,
                          (val) => setState(() => _m500GlassRailing = val),
                        ),
                        const Divider(),
                        _buildRadioGroup(
                          '용접 방식',
                          ['TWL', 'D-LINE'],
                          _m500Welding,
                          (val) => setState(() => _m500Welding = val),
                        ),
                      ],

                      if (_selectedMaster == 'M300') ...[
                        _buildRadioGroup(
                          '하드웨어 선택',
                          ['TT', 'Turn Only', 'Tilt Only'],
                          _m300Hardware,
                          (val) => setState(() => _m300Hardware = val),
                        ),
                        const Divider(),
                        _buildRadioGroup(
                          '외부 마감',
                          ['AL CAP', 'PVC'],
                          _m300Finishing,
                          (val) => setState(() => _m300Finishing = val),
                        ),
                      ],

                      if (_selectedMaster == 'Z350') ...[
                        _buildRadioGroup(
                          '내부 색상',
                          ['White', '랩핑'],
                          _z350InnerColor,
                          (val) => setState(() => _z350InnerColor = val),
                        ),
                        const Divider(),
                        _buildRadioGroup(
                          '내창 외면',
                          ['White', 'ASA'],
                          _z350InnerFace,
                          (val) => setState(() => _z350InnerFace = val),
                        ),
                        const Divider(),
                        _buildRadioGroup(
                          '외창 외면',
                          ['ASA', 'AL CAP'],
                          _z350OuterFace,
                          (val) => setState(() => _z350OuterFace = val),
                        ),
                        const Divider(),
                        _buildRadioGroup(
                          '방충망/핸들',
                          ['미적용', '적용'],
                          _z350ScreenHandle,
                          (val) => setState(() => _z350ScreenHandle = val),
                        ),
                        const Divider(),
                        _buildRadioGroup(
                          '유리난간대',
                          ['미적용', '적용'],
                          _z350GlassRailing,
                          (val) => setState(() => _z350GlassRailing = val),
                        ),
                        const Divider(),
                        _buildRadioGroup(
                          '용접 방식',
                          ['TWL', 'D-LINE'],
                          _z350Welding,
                          (val) => setState(() => _z350Welding = val),
                        ),
                      ],

                      if (_selectedMaster == 'IBF225') ...[
                        _buildRadioGroup(
                          '하드웨어 선택',
                          ['TT', 'Turn Only', 'Tilt Only'],
                          _ibfHardware,
                          (val) => setState(() => _ibfHardware = val),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // ─── [구간 5] 하단 고정바: 견적 산출 버튼 + 최종 금액 표시 ───
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF1E3A8A),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // 🟠 새로 추가된 [견적 산출] 버튼
                ElevatedButton.icon(
                  onPressed: () {
                    _unfocus();
                    _calculate(); // 👈 버튼 클릭 시에만 금액 산출 실행
                  },
                  label: const Text(
                    '견적 산출',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 금액 출력부
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '최종 금액',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${_finalResult.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 원',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioGroup(
    String title,
    List<String> options,
    String currentGroupValue,
    Function(String) onChangeCall, {
    List<String>? secondaryOptions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.indigo,
          ),
        ),
        Wrap(
          spacing: 5,
          runSpacing: -5,
          children: options
              .map(
                (opt) => SizedBox(
                  width: 150,
                  child: RadioListTile<String>(
                    title: Text(opt, style: const TextStyle(fontSize: 12)),
                    value: opt,
                    groupValue: currentGroupValue,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) {
                      _unfocus();
                      onChangeCall(val!);
                      // 값 변경 시 혼선을 줄이기 위해 이전 계산 결과를 0원으로 가림
                      setState(() {
                        _finalResult = 0;
                      });
                    },
                  ),
                ),
              )
              .toList(),
        ),
        if (secondaryOptions != null)
          Wrap(
            spacing: 5,
            runSpacing: -5,
            children: secondaryOptions
                .map(
                  (opt) => SizedBox(
                    width: 150,
                    child: RadioListTile<String>(
                      title: Text(opt, style: const TextStyle(fontSize: 12)),
                      value: opt,
                      groupValue: currentGroupValue,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        _unfocus();
                        onChangeCall(val!);
                        setState(() {
                          _finalResult = 0;
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
