import { useBackend, useSharedState } from '../backend';
import { Button, Flex, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const TachyonArray = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={550}
      height={250}
      resizable>
      <Window.Content scrollable>
      </Window.Content>
    </Window>
  );
};

export const TachyonArrayContent = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section>
    </Section>
  );
};
