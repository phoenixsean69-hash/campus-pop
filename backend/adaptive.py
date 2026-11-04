"""Conservative teaching-strategy selector; feedback is not proof of learning gain."""
from __future__ import annotations

STRATEGIES = ('worked example', 'guided questions', 'real-world analogy', 'retrieval practice')
MODE_DEFAULT = {'Explain':'worked example', 'Guided':'guided questions',
                'Practice':'retrieval practice', 'Summarise':'worked example'}


def choose_strategy(course:str, mode:str, stats:dict[str,tuple[int,float]]|None=None)->str:
    default=MODE_DEFAULT.get(mode,'worked example')
    stats=stats or {}
    # Until there are 5 explicit ratings for a strategy, stay with a pedagogical default.
    eligible=[(avg,n,which) for which,(n,avg) in stats.items() if n>=5 and which in STRATEGIES]
    if not eligible: return default
    # Only override if rated strategy has >=60% positive feedback.
    best=max(eligible)
    return best[2] if best[0]>=0.6 else default


def policy_instruction(strategy:str)->str:
    return {
      'worked example':'Include a short, fully worked example and a check-for-understanding question.',
      'guided questions':'Ask one purposeful hint or guiding question before giving the complete solution.',
      'real-world analogy':'Use a relevant everyday analogy; clearly state where it stops being exact.',
      'retrieval practice':'Ask one targeted practice question and offer feedback after the learner responds.'
    }.get(strategy,'Use clear examples and checks for understanding.')
